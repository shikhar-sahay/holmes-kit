using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics;
using System.Security.Principal;
using System.Windows;
using System.Windows.Data;
using HolmesKit.Desktop.Models;
using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.ViewModels;

public sealed class MainViewModel : ObservableObject
{
    private readonly IHolmesKitCommandService service;
    private readonly IHolmesKitPathResolver paths;
    private CancellationTokenSource? operationCancellation;
    private bool isBusy;
    private string status = "Ready";
    private string operationTitle = "No operation running";
    private SystemSnapshot system = new();
    private StartupEntry? selectedStartup;
    private InstalledApplication? selectedApplication;
    private string appFilter = "";
    private string startupFilter = "";
    private string logText = "No log has been created yet.";
    private string backupStatus = "Checking backup...";
    private string backupTimestamp = "";
    private bool hasBackup;
    private int selectedPageIndex;

    public MainViewModel(IHolmesKitCommandService service, IHolmesKitPathResolver paths)
    {
        this.service = service;
        this.paths = paths;
        RunOperationCommand = new AsyncRelayCommand(RunOperationAsync, p => p is OperationDefinition && !IsBusy);
        RefreshSystemCommand = new AsyncRelayCommand(_ => RefreshSystemAsync(), _ => !IsBusy);
        RefreshStartupCommand = new AsyncRelayCommand(_ => RefreshStartupAsync(), _ => !IsBusy);
        ToggleStartupCommand = new AsyncRelayCommand(ToggleStartupAsync, p => p is StartupEntry { Locked: false } && !IsBusy);
        RefreshApplicationsCommand = new AsyncRelayCommand(_ => RefreshApplicationsAsync(), _ => !IsBusy);
        UninstallCommand = new AsyncRelayCommand(UninstallAsync, p => p is InstalledApplication && !IsBusy);
        RefreshLogsCommand = new RelayCommand(_ => RefreshLogs());
        OpenLogFolderCommand = new RelayCommand(_ => OpenLogFolder());
        CopyLogsCommand = new RelayCommand(_ => CopyLogs());
        ClearActivityCommand = new RelayCommand(_ => Activity.Clear());
        NavigateCommand = new RelayCommand(Navigate);
        CancelCommand = new RelayCommand(_ => operationCancellation?.Cancel(), _ => IsBusy);
        StartupView = CollectionViewSource.GetDefaultView(StartupEntries);
        StartupView.Filter = item => item is StartupEntry entry && (string.IsNullOrWhiteSpace(StartupFilter) || entry.Name.Contains(StartupFilter, StringComparison.CurrentCultureIgnoreCase) || entry.Command.Contains(StartupFilter, StringComparison.CurrentCultureIgnoreCase));
        ApplicationsView = CollectionViewSource.GetDefaultView(Applications);
        ApplicationsView.Filter = item => item is InstalledApplication app && (string.IsNullOrWhiteSpace(AppFilter) || app.Name.Contains(AppFilter, StringComparison.CurrentCultureIgnoreCase) || app.Publisher.Contains(AppFilter, StringComparison.CurrentCultureIgnoreCase));
    }

    public IReadOnlyList<OperationDefinition> CoreOperations => OperationCatalog.All.Where(x => x.Category == "Core").ToList();
    public IReadOnlyList<OperationDefinition> AdvancedOperations => OperationCatalog.All.Where(x => x.Category == "Advanced").ToList();
    public IReadOnlyList<OperationDefinition> GamingOperations => OperationCatalog.All.Where(x => x.Category == "Gaming").ToList();
    public IReadOnlyList<OperationDefinition> RestoreOperations => OperationCatalog.All.Where(x => x.Category == "Restore").ToList();
    public OperationDefinition ApplyAllOperation => OperationCatalog.All.Single(x => x.Category == "ApplyAll");
    public ObservableCollection<string> Activity { get; } = [];
    public ObservableCollection<StartupEntry> StartupEntries { get; } = [];
    public ObservableCollection<InstalledApplication> Applications { get; } = [];
    public ObservableCollection<string> RecentActivity { get; } = [];
    public ICollectionView StartupView { get; }
    public ICollectionView ApplicationsView { get; }

    public AsyncRelayCommand RunOperationCommand { get; }
    public AsyncRelayCommand RefreshSystemCommand { get; }
    public AsyncRelayCommand RefreshStartupCommand { get; }
    public AsyncRelayCommand ToggleStartupCommand { get; }
    public AsyncRelayCommand RefreshApplicationsCommand { get; }
    public AsyncRelayCommand UninstallCommand { get; }
    public RelayCommand RefreshLogsCommand { get; }
    public RelayCommand OpenLogFolderCommand { get; }
    public RelayCommand CopyLogsCommand { get; }
    public RelayCommand ClearActivityCommand { get; }
    public RelayCommand NavigateCommand { get; }
    public RelayCommand CancelCommand { get; }
    public Func<string, string, bool>? Confirm { get; set; }
    public Action<string, string, MessageBoxImage>? Notify { get; set; }

    public bool IsAdministrator
    {
        get
        {
            using var identity = WindowsIdentity.GetCurrent();
            return new WindowsPrincipal(identity).IsInRole(WindowsBuiltInRole.Administrator);
        }
    }
    public string ElevationText => IsAdministrator ? "Administrator" : "Not elevated";
    public bool IsBusy { get => isBusy; private set { if (Set(ref isBusy, value)) RefreshCommandStates(); } }
    public string Status { get => status; private set => Set(ref status, value); }
    public string OperationTitle { get => operationTitle; private set => Set(ref operationTitle, value); }
    public SystemSnapshot System { get => system; private set => Set(ref system, value); }
    public StartupEntry? SelectedStartup { get => selectedStartup; set => Set(ref selectedStartup, value); }
    public InstalledApplication? SelectedApplication { get => selectedApplication; set => Set(ref selectedApplication, value); }
    public int SelectedPageIndex { get => selectedPageIndex; set => Set(ref selectedPageIndex, value); }
    public string StartupFilter { get => startupFilter; set { if (Set(ref startupFilter, value)) StartupView.Refresh(); } }
    public string AppFilter { get => appFilter; set { if (Set(ref appFilter, value)) ApplicationsView.Refresh(); } }
    public string LogText { get => logText; private set => Set(ref logText, value); }
    public string BackupStatus { get => backupStatus; private set => Set(ref backupStatus, value); }
    public string BackupTimestamp { get => backupTimestamp; private set => Set(ref backupTimestamp, value); }
    public bool HasBackup { get => hasBackup; private set => Set(ref hasBackup, value); }

    public async Task InitializeAsync()
    {
        RefreshLogs();
        UpdateBackupSummary();
        await RefreshSystemAsync();
    }

    private async Task RunOperationAsync(object? parameter)
    {
        if (parameter is not OperationDefinition operation) return;
        var message = $"{operation.Description}\n\nAffected: {operation.Affects}\nTradeoff: {operation.Tradeoff}\nRestart/logoff: {operation.Restart}\n\nHolmesKit will create or use its latest backup before applying changes. Continue?";
        if (Confirm?.Invoke(operation.Name, message) != true) return;
        await WithBusyAsync(operation.Name, async token =>
        {
            Activity.Clear();
            Activity.Add("Creating or validating backup...");
            var progress = new Progress<string>(line => Activity.Add(line));
            var result = await service.RunOperationAsync(operation.Id, progress, token);
            if (result.WasCancelled) { Activity.Add("Operation cancelled."); Status = "Cancelled"; return; }
            if (!result.Succeeded)
            {
                var detail = string.IsNullOrWhiteSpace(result.StandardError) ? result.StandardOutput : result.StandardError;
                Activity.Add($"Failed (exit code {result.ExitCode}).");
                throw new InvalidOperationException(string.IsNullOrWhiteSpace(detail) ? "The HolmesKit command failed without diagnostic output." : detail.Trim());
            }
            Activity.Add("Completed successfully.");
            Status = "Completed";
            RefreshLogs();
            UpdateBackupSummary();
        });
    }

    private async Task RefreshSystemAsync() => await WithBusyAsync("Refreshing system information", async token =>
    {
        System = await service.GetSystemInfoAsync(token);
        Status = "System information updated";
    }, showErrors: false);

    private async Task RefreshStartupAsync() => await WithBusyAsync("Scanning startup entries", async token =>
    {
        var entries = await service.GetStartupEntriesAsync(token);
        StartupEntries.Clear(); foreach (var entry in entries) StartupEntries.Add(entry);
        Status = $"{entries.Count} startup entries found";
    });

    private async Task ToggleStartupAsync(object? parameter)
    {
        if (parameter is not StartupEntry entry || entry.Locked) return;
        var next = entry.Status == "Enabled" ? "disable" : "enable";
        if (Confirm?.Invoke("Change startup entry", $"{next.ToUpperInvariant()} {entry.Name}?\n\nThe entry is preserved; HolmesKit only changes its enabled state.") != true) return;
        await WithBusyAsync($"Updating {entry.Name}", async token =>
        {
            var result = await service.ToggleStartupAsync(entry, token);
            if (!result.Succeeded) throw new InvalidOperationException(result.StandardError.Trim());
            await ReloadStartupAsync(token);
            Status = $"Startup entry updated: {entry.Name}";
        });
    }

    private async Task ReloadStartupAsync(CancellationToken token)
    {
        var entries = await service.GetStartupEntriesAsync(token);
        StartupEntries.Clear(); foreach (var item in entries) StartupEntries.Add(item);
    }

    private async Task RefreshApplicationsAsync() => await WithBusyAsync("Loading installed applications", async token =>
    {
        var apps = await service.GetApplicationsAsync(token);
        Applications.Clear(); foreach (var app in apps) Applications.Add(app);
        Status = $"{apps.Count} installed applications found";
    });

    private async Task UninstallAsync(object? parameter)
    {
        if (parameter is not InstalledApplication app) return;
        if (Confirm?.Invoke("Launch uninstaller", $"Launch the registered uninstaller for {app.Name}?\n\nHolmesKit does not remove files directly. The application's own uninstaller controls the changes.") != true) return;
        await WithBusyAsync($"Uninstalling {app.Name}", async token =>
        {
            var result = await service.UninstallAsync(app, token);
            if (!result.Succeeded) throw new InvalidOperationException(result.StandardError.Trim());
            Status = $"Uninstaller finished: {app.Name}";
        });
    }

    private async Task WithBusyAsync(string title, Func<CancellationToken, Task> action, bool showErrors = true)
    {
        if (IsBusy) return;
        IsBusy = true; OperationTitle = title; Status = "Working...";
        operationCancellation = new();
        try { await action(operationCancellation.Token); }
        catch (OperationCanceledException) { Status = "Cancelled"; }
        catch (Exception ex)
        {
            Status = "Failed";
            Activity.Add($"Error: {ex.Message}");
            AppendGuiLog($"{title} failed: {ex.Message}");
            if (showErrors) Notify?.Invoke("HolmesKit could not complete the operation", ex.Message, MessageBoxImage.Error);
        }
        finally { operationCancellation.Dispose(); operationCancellation = null; IsBusy = false; }
    }

    private void RefreshLogs()
    {
        try
        {
            if (!File.Exists(paths.LogFile)) { LogText = "No HolmesKit log has been created yet."; RecentActivity.Clear(); return; }
            var lines = File.ReadLines(paths.LogFile).TakeLast(500);
            var materialized = lines.ToList();
            LogText = string.Join(Environment.NewLine, materialized);
            RecentActivity.Clear();
            foreach (var line in materialized.TakeLast(4).Reverse()) RecentActivity.Add(line);
        }
        catch (Exception ex) { LogText = $"Unable to read the log: {ex.Message}"; }
    }

    private void OpenLogFolder()
    {
        var folder = Path.GetDirectoryName(paths.LogFile)!;
        Directory.CreateDirectory(folder);
        Process.Start(new ProcessStartInfo("explorer.exe", folder) { UseShellExecute = true });
    }

    private void CopyLogs()
    {
        try
        {
            if (!string.IsNullOrWhiteSpace(LogText))
            {
                Clipboard.SetText(LogText);
                Status = "Log copied to clipboard";
            }
        }
        catch (Exception ex)
        {
            Status = "Copy failed";
            Notify?.Invoke("Unable to copy the log", ex.Message, MessageBoxImage.Error);
        }
    }

    private void Navigate(object? parameter)
    {
        if (parameter is int index) SelectedPageIndex = index;
        else if (int.TryParse(parameter?.ToString(), out var parsed)) SelectedPageIndex = parsed;
    }

    private void UpdateBackupSummary()
    {
        var backup = Path.Combine(paths.RootDirectory, "HolmesKit_Backups", "latest");
        try
        {
            var exists = Directory.Exists(backup) && Directory.EnumerateFiles(backup).Any();
            HasBackup = exists;
            BackupStatus = exists ? "Backup available" : "No backup detected";
            BackupTimestamp = exists ? $"Updated {Directory.GetLastWriteTime(backup):MMM d, yyyy · h:mm tt}" : "Created automatically before optimization";
        }
        catch
        {
            HasBackup = false;
            BackupStatus = "Backup status unavailable";
            BackupTimestamp = "Check HolmesKit_Backups manually";
        }
    }

    private void AppendGuiLog(string message)
    {
        try
        {
            Directory.CreateDirectory(Path.GetDirectoryName(paths.LogFile)!);
            File.AppendAllText(paths.LogFile, $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] GUI: {message}{Environment.NewLine}");
        }
        catch { }
    }

    private void RefreshCommandStates()
    {
        RunOperationCommand.RaiseCanExecuteChanged(); RefreshSystemCommand.RaiseCanExecuteChanged(); RefreshStartupCommand.RaiseCanExecuteChanged();
        ToggleStartupCommand.RaiseCanExecuteChanged(); RefreshApplicationsCommand.RaiseCanExecuteChanged(); UninstallCommand.RaiseCanExecuteChanged(); CancelCommand.RaiseCanExecuteChanged();
    }
}
