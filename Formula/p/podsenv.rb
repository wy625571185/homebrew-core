class PodsEnv < Formula
  desc "管理 CocoaPods 版本的工具，功能类似 pyenv"
  homepage "https://github.com/wy625571185/podsenv.git" # 替换为你的 GitHub 仓库地址
  url "https://github.com/wy625571185/podsenv/archive/refs/tags/v1.0.0.tar.gz" # 替换为你的仓库的 tar.gz 链接
  sha256 "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed" # 替换为你的 tar.gz 文件的 SHA-256 哈希值
  license "MIT"

  def install
    bin.install "podsenv"
  end

  test do
    system "#{bin}/podsenv", "list-available"
  end
end
