
public static class build_runner {

	public static int build_process_id = 0;

	public static bool build_module(
		string current_working_directory
		, string module_name
		, string build_cmd
		, bool log_2_console = false
	) {
		build_process_id = 0;
		Console.WriteLine( "[{0}] building via [{1}]", module_name, build_cmd );
		string log_file = Path.Combine( current_working_directory, "build-logs", module_name + ".txt" );
		DateTime time_start = DateTime.Now;
		bool build_success = true;

		try {
			using (FileStream fs = new FileStream( log_file, FileMode.Create, FileAccess.Write, FileShare.ReadWrite )) {
				using (TextWriter tw = new StreamWriter( fs, Encoding.UTF8 )) {
					using (Process p = new Process()) {
						p.StartInfo = new ProcessStartInfo( "cmd", @"/c """ + build_cmd + "\"" )
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
						build_process_id = p.Id;
						p.BeginOutputReadLine();
						p.BeginErrorReadLine();
						p.WaitForExit();

						DateTime time_finish = DateTime.Now;
						Console.WriteLine(
							"[{0}] build duration {1} minutes"
							, module_name
							, time_finish.Subtract( time_start ).TotalMinutes
						);

						Console.WriteLine( "build process exit code: {0}", p.ExitCode );
						build_success = 0 == p.ExitCode;
						return build_success;
					}
				}
			}
		}
		catch(Exception ex) {
			Console.WriteLine( ex );
			return false;
		}
		finally {
			build_process_id = 0;
			if (!build_success) {
				try {
					using (TextReader tr = new StreamReader(log_file)) {
						string line;
						while (null!=(line=tr.ReadLine()) ) {
							Console.WriteLine( line );
						}
					}
				}
				catch (Exception ex2) {
					Console.WriteLine( ex2 );
				}
			}
		}
	}


	public static bool abort_build() {
		try {
			Console.WriteLine( " .... ABORTING BUILD ...." );
			if (0 == build_process_id) {
				Console.WriteLine( "no running build process" );
				return true;
			}
			kill_process_and_children( build_process_id );
			return true;
		}
		catch (Exception ex) {

			return false;
		}
	}


	private static void kill_process_and_children( int pid ) {

		ManagementObjectSearcher searcher = new ManagementObjectSearcher
		  ( "Select * From Win32_Process Where ParentProcessID=" + pid );

		ManagementObjectCollection moc = searcher.Get();

		foreach (ManagementObject mo in moc) {
			kill_process_and_children( Convert.ToInt32( mo["ProcessID"] ) );
		}

		try {
			Console.WriteLine( "about to kill process: {0}", pid );
			Process proc = Process.GetProcessById( pid );
			proc.Kill();
		}
		catch (ArgumentException) {
			// Process already exited.
		}
		catch (Exception ex) {
			Console.WriteLine( "Exception killing process [{0}]:{1}{2}", pid, Environment.NewLine, ex );
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
