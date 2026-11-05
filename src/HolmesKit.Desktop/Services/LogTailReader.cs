using System.Text;

namespace HolmesKit.Desktop.Services;

public static class LogTailReader
{
    public static string[] Read(string path, int lines = 500)
    {
        using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete);
        var length = stream.Length;
        var start = Math.Max(0, length - 262144);
        stream.Seek(start, SeekOrigin.Begin);
        // Snapshot the bounded suffix. A continuously appending writer cannot extend this read.
        var bytes = new byte[(int)(length - start)];
        var read = 0;
        while (read < bytes.Length)
        {
            var count = stream.Read(bytes, read, bytes.Length - read);
            if (count == 0) break;
            read += count;
        }
        using var snapshot = new MemoryStream(bytes, 0, read);
        using var reader = new StreamReader(snapshot, Encoding.UTF8, true);
        if (start > 0) reader.ReadLine(); // discard a partial UTF-8 line at the bounded seek position
        var queue = new Queue<string>();
        while (reader.ReadLine() is { } line) { queue.Enqueue(line); if (queue.Count > lines) queue.Dequeue(); }
        return queue.ToArray();
    }
}
