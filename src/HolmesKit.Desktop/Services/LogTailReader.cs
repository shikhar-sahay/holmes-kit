using System.Text;

namespace HolmesKit.Desktop.Services;

public static class LogTailReader
{
    public static string[] Read(string path, int lines = 500)
    {
        using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete);
        var start = Math.Max(0, stream.Length - 262144);
        stream.Seek(start, SeekOrigin.Begin);
        using var reader = new StreamReader(stream, Encoding.UTF8, true);
        if (start > 0) reader.ReadLine(); // discard a partial UTF-8 line at the bounded seek position
        var queue = new Queue<string>();
        while (reader.ReadLine() is { } line) { queue.Enqueue(line); if (queue.Count > lines) queue.Dequeue(); }
        return queue.ToArray();
    }
}
