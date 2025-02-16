class Wownero < Formula
  desc "Official wallet and node software for the Wownero cryptocurrency"
  homepage "https://wownero.org"
  # TODO: Check if we can use unversioned `protobuf` at version bump
  url "https://git.wownero.com/wownero/wownero.git",
      tag:      "v0.11.0.3",
      revision: "e921c3b8a35bc497ef92c4735e778e918b4c4f99"
  license "BSD-3-Clause"
  revision 1

  # The `strategy` code below can be removed if/when this software exceeds
  # version 10.0.0. Until then, it's used to omit a malformed tag that would
  # always be treated as newest.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :git do |tags, regex|
      malformed_tags = ["10.0.0"].freeze
      tags.map do |tag|
        next if malformed_tags.include?(tag)

        tag[regex, 1]
      end
    end
  end

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "2bf3e20f48c0b92b2bfc74feaee831b3849c56239a0d9e1da6a54f49e36da19b"
    sha256 cellar: :any,                 arm64_monterey: "deb50ecc4a6e3bc42672a7ebd5ed49fef415d2590735fc9cef2e883627f3a669"
    sha256 cellar: :any,                 arm64_big_sur:  "face536fbc52d85877bd7a680e37b45488e79b8f5be491a89846ca78157eb88d"
    sha256 cellar: :any,                 ventura:        "7952e31288138949ede6b78adce699ccee81cf289ac0e4854da9f6eab8fefd4e"
    sha256 cellar: :any,                 monterey:       "8d9ae5c1457454103f82e0c25f8748dd18e3b1cfc4200cb8e286104690696b41"
    sha256 cellar: :any,                 big_sur:        "88f65079dab113125350e18dff96884cf3d00502cad966debd73e1a002520975"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "414dc04013fed7567286ef00d8c066dca39c37404c06d7d7863cfb798dddf8a4"
  end

  depends_on "cmake" => :build
  depends_on "miniupnpc" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "hidapi"
  depends_on "libsodium"
  depends_on "libusb"
  depends_on "openssl@1.1"
  depends_on "protobuf@21"
  depends_on "readline"
  depends_on "unbound"
  depends_on "zeromq"

  conflicts_with "monero", because: "both install a wallet2_api.h header"

  def install
    # Need to help CMake find `readline` when not using /usr/local prefix
    args = %W[-DReadline_ROOT_DIR=#{Formula["readline"].opt_prefix}]

    # Build a portable binary (don't set -march=native)
    args << "-DARCH=default" if build.bottle?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  service do
    run [opt_bin/"wownerod", "--non-interactive"]
  end

  test do
    cmd = "yes '' | #{bin}/wownero-wallet-cli --restore-deterministic-wallet " \
          "--password brew-test --restore-height 238084 --generate-new-wallet wallet " \
          "--electrum-seed 'maze vixen spiders luggage vibrate western nugget older " \
          "emails oozed frown isolated ledge business vaults budget " \
          "saucepan faxed aloof down emulate younger jump legion saucepan'" \
          "--command address"
    address = "Wo3YLuTzJLTQjSkyNKPQxQYz5JzR6xi2CTS1PPDJD6nQAZ1ZCk1TDEHHx8CRjHNQ9JDmwCDGhvGF3CZXmmX1sM9a1YhmcQPJM"
    assert_equal address, shell_output(cmd).lines.last.split[1]
  end
end
