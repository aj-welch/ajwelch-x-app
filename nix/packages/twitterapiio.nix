{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "twitterapiio";
  version = "2025-02-16";

  # OpenAPI spec
  specSrc = fetchurl {
    url = "https://docs.twitterapi.io/api-reference/openapi.json";
    hash = "sha256-UtXVoWlFfI/yKVg1hgrUhBv1qZwF+/btNMHdjRtFy1M=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    # Copy OpenAPI spec to proper location
    cp ${specSrc} openapi.json

    # Install OpenAPI spec
    mkdir -p $out/share/twitterapiio
    cp openapi.json $out/share/twitterapiio/openapi.json

    runHook postInstall
  '';

  meta = with lib; {
    description = "TwitterAPI.io OpenAPI specification";
    homepage = "https://twitterapi.io";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
