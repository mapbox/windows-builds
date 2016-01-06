#load "build-targets.csx"
#load "build-module.csx"

string cwd = Environment.CurrentDirectory;

string[] cmds = new string[] { "upto", "build", "from" };

if (1 != Env.ScriptArgs.Count) {
	Console.WriteLine( string.Format(
		"scriptcs build.csx -- <{0}>=<module>"
		, string.Join( "|", cmds )
	) );
	Console.WriteLine( "available modules: " );
	foreach (var module in target_mapnik.Select( m => m.Key )) {
		Console.WriteLine( "  {0}", module );
	}
	throw new ArgumentNullException( "no build command" );
}

string[] build_tokens = Env.ScriptArgs[0].Split( "=".ToCharArray(), StringSplitOptions.RemoveEmptyEntries );
if (build_tokens.Length < 2) { throw new ArgumentException( string.Format( "argument [{0}] not valid", Env.ScriptArgs[0] ) ); }

string cmd = build_tokens[0].ToLower();
string module = build_tokens[1].ToLower();

if (null == cmds.FirstOrDefault( c => c.Equals( cmd, StringComparison.OrdinalIgnoreCase ) )) {
	throw new ArgumentException( string.Format( "[{0}] is not a valid build argument", cmd ) );
}
if (default( string ) == target_mapnik.FirstOrDefault( t => t.Key.Equals( module, StringComparison.OrdinalIgnoreCase ) ).Key) {
	throw new ArgumentException( string.Format( "[{0}] is not a valid module", module ) );
}

if (cmd.Equals( "upto" )) {
	Console.WriteLine( "building up to {0}", module );
	foreach (var target in target_mapnik) {
		//Console.WriteLine( "building {0}, calling {1}", target.Key, target.Value );
		if(!build_runner.build_module(cwd, target.Key, target.Value )) {
			Console.WriteLine( "[{0}] !!!!!! BUILD FAILED !!!!!!", target.Key );
			break;
		}
		if (target.Key.Equals( module )) {
			break;
		}
	}
} else if (cmd.Equals( "build" )) {
	Console.WriteLine( "building just {0}, calling {1}", module, target_mapnik.FirstOrDefault( t => t.Key == module ).Value );
} else if (cmd.Equals( "from" )) {
	Console.WriteLine( "building from {0} on", module );
	bool do_build = false;
	foreach (var target in target_mapnik) {
		if (target.Key.Equals( module )) {
			do_build = true;
		}
		if (do_build) {
			Console.WriteLine( "building {0}, calling {1}", target.Key, target.Value );
		}
	}
} else {
	Console.WriteLine( "nothing to do" );
}

Console.WriteLine( "FINISHED" );
