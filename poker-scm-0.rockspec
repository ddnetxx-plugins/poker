package = "poker"
rockspec_format = "3.0"
version = "scm-0"
source = {
  url = "git+https://github.com/ddnetxx-plugins/poker.git",
  branch = "master"
}
description = {
  summary = "poker",
  detailed = "",
  license = "Zlib",
  homepage = "https://github.com/ddnetxx-plugins/poker",
  issues_url = "https://github.com/ddnetxx-plugins/poker/issues",
  maintainer = "ChillerDragon <chillerdragon@gmail.com>",
  labels = { "teeworlds", "ddnet", "ddracenetwork", "game", "poker", "texas" }
}
dependencies = {
  "lua >= 5.1, <= 5.5"
}
test_dependencies = {
   "simple-assert",
}
test = {
  type = "command",
  command = "make test"
}
build = {
  type = "builtin",
}
