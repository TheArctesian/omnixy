# tobi-try: `try`, fresh directories for every experiment (in Omarchy's base
# packages; the bash init wraps it). Same files as upstream's Arch package.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ruby,
}:
stdenvNoCC.mkDerivation rec {
  pname = "tobi-try";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "tobi";
    repo = "try";
    rev = "v${version}";
    hash = "sha256-ZSt6LSp0AQTbdN86lJGJPWcx6oFR63AFi4s8Vjr5a5o=";
  };

  buildInputs = [ ruby ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 try.rb $out/lib/tobi-try/try.rb
    # The generated shell function runs `ruby`; pin it, as upstream pins
    # /usr/bin/ruby, so a mise-managed ruby can't break `try`.
    substituteInPlace $out/lib/tobi-try/try.rb --replace-fail "/usr/bin/env ruby" "${ruby}/bin/ruby"
    install -Dm644 lib/tui.rb $out/lib/tobi-try/lib/tui.rb
    install -Dm644 lib/fuzzy.rb $out/lib/tobi-try/lib/fuzzy.rb
    mkdir -p $out/bin
    ln -s $out/lib/tobi-try/try.rb $out/bin/try
    runHook postInstall
  '';

  meta = {
    description = "Fresh directories for every vibe";
    homepage = "https://github.com/tobi/try";
    license = lib.licenses.mit;
    mainProgram = "try";
    platforms = lib.platforms.all;
  };
}
