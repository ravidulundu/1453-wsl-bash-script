<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# how to install go on linux

To install Go (Golang) on Linux, download the official package, extract it, set up your environment variables, and verify the installation. Both distribution package managers and official binaries are supported, but using the official binary will give you the latest version.[^1][^2][^3]

### Official Go Installation (Generic Linux)

1. **Download the latest Go Linux binary** from the Go official downloads page.[^2][^3][^1]

```
wget https://go.dev/dl/go<version>.linux-amd64.tar.gz
```

Replace `<version>` with the desired release.
2. **Extract the tarball to `/usr/local`**:

```
sudo tar -C /usr/local -xzf go<version>.linux-amd64.tar.gz
```

3. **Set up environment variables** (you can add these lines to your `~/.profile`, `~/.bashrc`, or `/etc/profile`):

```
export PATH=$PATH:/usr/local/go/bin
```

For per-user installs, also set your `GOPATH` and update `PATH` accordingly:

```
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

4. **Apply the changes.**

```
source ~/.profile
```

5. **Verify installation:**

```
go version
```

This should output the installed version.[^4][^3][^1][^2]

### Ubuntu: Alternative via Package Manager

- Fastest way (may not be the latest version):

```
sudo apt update
sudo apt install golang-go
```

To install specific Go versions, use:

```
sudo apt install golang-1.21 golang-1.23
```

The Go binaries will be found in `/usr/lib/go-<version>/bin/`.[^5][^6]


### Fedora: Package Manager or Official Binary

- Package Manager Method:

```
sudo dnf install golang
```

This is the fastest method, but it may not provide the newest release.[^7][^8][^9][^10]
- Manual Official Method:

```
wget https://go.dev/dl/go<version>.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go<version>.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version
```

This ensures the latest version.[^4]


### Summary Table

| Linux Distribution | Package Manager Install | Official Binary Install |
| :-- | :-- | :-- |
| Ubuntu | `sudo apt install golang-go` [^3] | See steps above, use official tarball [^2][^3] |
| Fedora | `sudo dnf install golang` [^8] | See steps above, use official tarball [^4] |
| Any Linux | Not always latest version | Most up-to-date, same steps everywhere [^1][^2] |

This guide applies to recent distributions such as Ubuntu 22.04/24.04 and Fedora 39/40, including the latest Go releases.[^11][^10][^5]

You can always verify your installation by running:

```
go version
```

This command prints the installed version and confirms correct setup.[^3][^1][^2]
<span style="display:none">[^12][^13][^14][^15][^16][^17][^18][^19][^20]</span>

<div align="center">⁂</div>

[^1]: https://go.dev/doc/install

[^2]: https://gist.github.com/missinglink/4212a81a7d9c125b68d9

[^3]: https://www.cherryservers.com/blog/install-go-ubuntu

[^4]: https://utho.com/docs/linux/fedora/how-to-install-go-on-fedora/

[^5]: https://documentation.ubuntu.com/ubuntu-for-developers/howto/go-setup/

[^6]: https://linuxconfig.org/how-to-install-go-on-ubuntu-22-04-jammy-jellyfish-linux

[^7]: https://www.atlantic.net/dedicated-server-hosting/how-to-install-golang-on-fedora/

[^8]: https://developer.fedoraproject.org/tech/languages/go/go-installation.html

[^9]: https://www.reddit.com/r/linux4noobs/comments/1ecbvfv/how_do_i_actually_install_go_on_fedora/

[^10]: https://linuxcapable.com/how-to-install-golang-on-fedora-linux/

[^11]: https://www.cherryservers.com/blog/install-go-ubuntu-2404

[^12]: https://www.geeksforgeeks.org/installation-guide/how-to-install-go-programming-language-in-linux/

[^13]: https://www.ovhcloud.com/en/community/tutorials/how-to-install-go-ubuntu/

[^14]: https://www.youtube.com/watch?v=sqHUSL0l2OM

[^15]: https://go.dev/wiki/Ubuntu

[^16]: https://www.bytesizego.com/blog/installing-golang

[^17]: https://phoenixnap.com/kb/debian-install-go

[^18]: https://www.digitalocean.com/community/tutorials/how-to-install-go-on-ubuntu-20-04

[^19]: https://www.cyberciti.biz/faq/how-to-install-gol-ang-on-ubuntu-linux/

[^20]: https://discussion.fedoraproject.org/t/fedora-doesnt-provide-latest-version-of-go/146930

