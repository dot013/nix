{lib, ...}:
with lib; {
  options.context = mkOption {
    type = with types; let
      primitive = oneOf [
        bool
        int
        str
        path
        (attrsOf primitive)
        (listOf primitive)
      ];
    in
      attrsOf primitive;
    default = {};
  };
}
