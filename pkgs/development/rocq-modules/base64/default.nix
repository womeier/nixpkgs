{
  lib,
  mkRocqDerivation,
  metarocq-utils,
  stdlib,
  rocq-core,
  version ? null,
}:

# Two packages out of one repo:
# - base64: the library itself
# - base64.bytestring: additional support for MetaRocq's bytestring
let
  common = {
    owner = "womeier";
    repo = "rocq-base64";

    inherit version;
    defaultVersion = lib.switch rocq-core.rocq-version [
      {
        case = lib.versions.isGe "9.0";
        out = "0.1.0";
      }
    ] null;

    release."0.1.0".hash = "sha256-IRVY9qt3zwRKsYDNA8bJkMxJv+Oh6NUnF6aLs/lhOig=";
    releaseRev = v: "v${v}";

    meta = {
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ womeier ];
    };
  };

  base64 = mkRocqDerivation (
    common
    // {
      pname = "base64";

      propagatedBuildInputs = [ stdlib ];

      passthru.bytestring = bytestring;

      meta = common.meta // {
        description = "Verified base64 encoding and decoding in Rocq";
      };
    }
  );

  bytestring = mkRocqDerivation (
    common
    // {
      pname = "base64-bytestring";

      # Its own project, with its own _RocqProject and makefile; it resolves
      # Base64 through ROCQPATH, from the installed library.
      preBuild = "cd bytestring";

      # findlib puts MetaRocq's transitive equations plugin on OCAMLPATH, for
      # consumers of this library as much as for the build itself.
      propagatedBuildInputs = [
        base64
        metarocq-utils
        rocq-core.ocamlPackages.findlib
      ];

      meta = common.meta // {
        description = "MetaRocq bytestring support for rocq-base64";
      };
    }
  );
in
base64
