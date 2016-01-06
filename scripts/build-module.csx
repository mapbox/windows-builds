using System.Diagnostics;
using System.Text;

public static class build_runner {


	public static bool build_module(
		string current_working_directory
		, string module_name
		, string build_cmd
		, bool log_2_console = false
	) {
		Console.WriteLine( "[{0}] building via [{1}]", module_name, build_cmd );
		string log_file = Path.Combine( current_working_directory, "build-logs", module_name + ".txt" );
		DateTime time_start = DateTime.Now;

		using (FileStream fs = new FileStream( log_file, FileMode.Create, FileAccess.Write, FileShare.ReadWrite )) {
			using (TextWriter tw = new StreamWriter( fs, Encoding.UTF8 )) {
				using (Process p = new Process()) {
					p.StartInfo = new ProcessStartInfo( "cmd", @"/c """ + build_cmd + "\"" )
					//p.StartInfo = new ProcessStartInfo("cmd", @"/c " + command)
					{
						UseShellExecute = false,
						CreateNoWindow = true,
						RedirectStandardOutput = true,
						RedirectStandardError = true,
						WorkingDirectory = current_working_directory,
						StandardOutputEncoding = Encoding.UTF8,
						StandardErrorEncoding = Encoding.UTF8
					};

					p.OutputDataReceived += ( sender, e ) => {
						string msg;
						if (e.Data != null) {
							msg = construct_message( e.Data, "stdout" );
						} else {
							msg = construct_message( "DATA:NULL", "stdout" );
						}
						tw.WriteLine( msg );
						tw.Flush();
						if (log_2_console) { Console.WriteLine( msg ); }
					};
					p.ErrorDataReceived += ( sender, e ) => {
						string msg;
						if (e.Data != null) {
							msg = construct_message( e.Data, "stderr" );
						} else {
							msg = construct_message( "ERROR:NULL", "stderr" );
						}
						tw.WriteLine( msg );
						tw.Flush();
						if (log_2_console) { Console.WriteLine( msg ); }
					};

					p.Start();
					Console.WriteLine( "[{0}] root build thread id: {1}", module_name, p.Id );
					p.BeginOutputReadLine();
					p.BeginErrorReadLine();
					p.WaitForExit();

					DateTime time_finish = DateTime.Now;
					Console.WriteLine(
						"[{0}] build duration {1} minutes"
						, module_name
						, time_finish.Subtract( time_start ).TotalMinutes
					);

					return 0 == p.ExitCode;
				}
			}
		}
	}


	private static string construct_message( string msg, string outputstream ) {
		return string.Format(
			"{1}{0}{2}{0}{3}"
			, "\t"
			, DateTime.Now.ToString( "yyyy-MM-dd HH:mm:ss" )
			, outputstream
			, msg
		);
	}



}
