{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
  jq,
  versionCheckHook,
}:

let
  # Written by update.sh from the npm registry.
  release = lib.importJSON ./release.json;
in
buildNpmPackage {
  pname = "creem-cli";
  inherit (release) version npmDepsHash;

  nodejs = nodejs_22;

  # The npm tarball ships the compiled CLI (dist/, from tsc); only its runtime
  # dependencies have to be installed.
  src = fetchurl {
    inherit (release) url hash;
  };
  sourceRoot = "package";

  # The tarball has no lockfile, so update.sh generates package-lock.json from
  # its runtime dependencies; drop the devDependencies so package.json matches it.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.new
    mv package.json.new package.json
  '';

  dontNpmBuild = true;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Creem's CLI (creem): products, checkouts, customers, subscriptions from the terminal";
    homepage = "https://docs.creem.io";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "creem";
  };
}
