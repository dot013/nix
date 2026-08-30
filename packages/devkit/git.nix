{
  lib,
  pkgs,
  wrapPackage,
  # Package
  git ? pkgs.git,
  pager ? pkgs.delta,
}:
with lib;
  wrapPackage {
    inherit pkgs;
    package = git;
    env =
      pipe {
        "core.pager" = getExe pager;
        "credentials.helper" = "store";
        "interactive.diffFilter" = "${getExe pager} --color-only";
        "signing.signByDefault" = "true";
        "user.email" = "contact@guz.one";
        "user.name" = ''Gustavo \"Guz\" L de Mello'';
        "commit.gpgsign" = "true";
      } [
        attrsToList
        (imap0 (i: c: {
          "GIT_CONFIG_KEY_${toString i}" = c.name;
          "GIT_CONFIG_VALUE_${toString i}" = c.value;
        }))
        (l:
          {
            GIT_CONFIG_COUNT = length l;
          }
          // (mergeAttrsList l))
      ];
  }
