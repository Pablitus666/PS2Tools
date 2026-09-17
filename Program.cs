using System.Diagnostics;
using System.IO.Compression;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Windows.Forms;

internal static class Program
{
    const string App="PS2Tools", Script="Get-PlayStationGame.ps1";
    static int Main()
    {
        try {
            var baseDir=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),App);
            var ps=Path.Combine(baseDir,"PowerShell");
            var rt=Path.Combine(baseDir,"Runtime");
            Directory.CreateDirectory(baseDir);
            Extract("PowerShell.Payload.zip",ps,Path.Combine(ps,".powershell-version"));
            Extract("PS2Tools.Payload.zip",rt,Path.Combine(rt,".payload-version"));
            var exe=Path.Combine(ps,"pwsh.exe");
            var script=Path.Combine(rt,Script);
            if(!File.Exists(exe)) throw new FileNotFoundException("No se encontró PowerShell 7 portable.",exe);
            if(!File.Exists(script)) throw new FileNotFoundException("No se encontró el script principal de PS2Tools.",script);
            var psi=new ProcessStartInfo { FileName=exe, UseShellExecute=false, CreateNoWindow=true, WindowStyle=ProcessWindowStyle.Hidden, WorkingDirectory=rt };
            foreach(var a in new[]{"-NoLogo","-NoProfile","-ExecutionPolicy","Bypass","-File",script}) psi.ArgumentList.Add(a);
            using var p=Process.Start(psi) ?? throw new InvalidOperationException("No se pudo iniciar PowerShell 7 portable.");
            p.WaitForExit();
            var report=Path.Combine(rt,"Output","PS2Tools-Report.html");
            if(p.ExitCode==0 && File.Exists(report)) Process.Start(new ProcessStartInfo{FileName=report,UseShellExecute=true});
            else if(p.ExitCode==1) MessageBox.Show("No se pudo completar la identificación del disco.\n\nVerifique que haya un disco PlayStation 2 insertado y que la unidad óptica esté disponible.",App,MessageBoxButtons.OK,MessageBoxIcon.Information);
            else if(p.ExitCode!=0) MessageBox.Show($"PS2Tools terminó con un código inesperado: {p.ExitCode}.",App,MessageBoxButtons.OK,MessageBoxIcon.Error);
            return p.ExitCode;
        } catch(Exception ex) { MessageBox.Show("PS2Tools no pudo iniciarse correctamente.\n\n"+ex.Message,App,MessageBoxButtons.OK,MessageBoxIcon.Error); return -1; }
    }
    static void Extract(string resource,string dest,string marker) {
        using var s=Assembly.GetExecutingAssembly().GetManifestResourceStream(resource) ?? throw new FileNotFoundException("Recurso no encontrado: "+resource);
        var hash=Convert.ToHexString(SHA256.HashData(s)); s.Position=0;
        if(File.Exists(marker) && string.Equals(File.ReadAllText(marker).Trim(),hash,StringComparison.OrdinalIgnoreCase)) return;
        var tmp=dest+".new"; if(Directory.Exists(tmp)) Directory.Delete(tmp,true); Directory.CreateDirectory(tmp);
        using(var z=new ZipArchive(s,ZipArchiveMode.Read)) foreach(var e in z.Entries) {
            var path=Safe(tmp,e.FullName);
            if(e.FullName.EndsWith("/")) { Directory.CreateDirectory(path); continue; }
            Directory.CreateDirectory(Path.GetDirectoryName(path)!); using var i=e.Open(); using var o=File.Create(path); i.CopyTo(o);
        }
        if(Directory.Exists(dest)) Directory.Delete(dest,true); Directory.Move(tmp,dest); File.WriteAllText(marker,hash,new UTF8Encoding(false));
    }
    static string Safe(string root,string name) {
        var rr=Path.GetFullPath(root)+Path.DirectorySeparatorChar;
        var p=Path.GetFullPath(Path.Combine(root,name.Replace('/',Path.DirectorySeparatorChar)));
        if(!p.StartsWith(rr,StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("El ZIP contiene una ruta no segura.");
        return p;
    }
}
