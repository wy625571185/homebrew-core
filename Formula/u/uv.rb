class Uv < Formula
  desc "Extremely fast Python package installer and resolver, written in Rust"
  homepage "https://github.com/astral-sh/uv"
  url "https://github.com/astral-sh/uv/archive/refs/tags/0.1.20.tar.gz"
  sha256 "ebac0fb2c1a84e6c88f68d6c5a803bb3768b5539043611408c125dbb258824c7"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/astral-sh/uv.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "35c3a879503a331cdd90b6fecfc67a8f028a17ac6a14011155063aa0ba7f1227"
    sha256 cellar: :any,                 arm64_ventura:  "3dc8b60c38af4bf29bc80f55b54375070dc669e02e388b320592b6cb19057dba"
    sha256 cellar: :any,                 arm64_monterey: "486baf84576dbe7c2b25196b8fe08ecd6f0cd8d3520f884c212a80fee6a887c9"
    sha256 cellar: :any,                 sonoma:         "a686470e2b842f0a0ade216b780108112ec004e61a38c0cac02c48b2281d6078"
    sha256 cellar: :any,                 ventura:        "a9e7f034af2a4f76202128c70991bbb4ce818fcbc20051dc1999372d0311c99d"
    sha256 cellar: :any,                 monterey:       "117538f9fcc56d0f56eab93f3db60f7666426d9b65b3b7da84629673bef1de96"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "2dcf54c9c4438e9b2dec5831c28d277dabcb0e7e0d1b5633d8fd548148d95836"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "libgit2"
  depends_on "openssl@3"

  uses_from_macos "python" => :test

  # https://github.com/astral-sh/uv/pull/2454
  # remove with next release
  patch do
    url "https://github.com/astral-sh/uv/commit/b5d90149180ae38de6798a4a857f72fc3d5a64e7.patch?full_index=1"
    sha256 "04fa2352cf0c84a880a19607041955d9148737fccbb2c454a9d0510f557b832f"
  end

  def install
    ENV["LIBGIT2_NO_VENDOR"] = "1"

    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix
    ENV["OPENSSL_NO_VENDOR"] = "1"

    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/uv")
    generate_completions_from_executable(bin/"uv", "generate-shell-completion")
  end

  def check_binary_linkage(binary, library)
    binary.dynamically_linked_libraries.any? do |dll|
      next false unless dll.start_with?(HOMEBREW_PREFIX.to_s)

      File.realpath(dll) == File.realpath(library)
    end
  end

  test do
    (testpath/"requirements.in").write <<~EOS
      requests
    EOS

    compiled = shell_output("#{bin}/uv pip compile -q requirements.in")
    assert_match "This file was autogenerated by uv", compiled
    assert_match "# via requests", compiled

    [
      Formula["libgit2"].opt_lib/shared_library("libgit2"),
      Formula["openssl@3"].opt_lib/shared_library("libssl"),
      Formula["openssl@3"].opt_lib/shared_library("libcrypto"),
    ].each do |library|
      assert check_binary_linkage(bin/"uv", library),
             "No linkage with #{library.basename}! Cargo is likely using a vendored version."
    end
  end
end
