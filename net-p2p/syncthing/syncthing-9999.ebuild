# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: This ebuild is from mva overlay; Bumped by mva; $

EAPI="5"

if [ "$PV" != "9999" ]; then
	SRC_URI="https://github.com/calmh/${PN}/archive/v${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm ~darwin ~winnt ~fbsd"
else
	vcs="git-r3"
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/calmh/${PN}"
	KEYWORDS=""
fi

inherit eutils base ${vcs}

DESCRIPTION="Open, trustworthy and decentralized syncing engine (some kind of analog of DropBox and BTSync)"
HOMEPAGE="http://syncthing.net"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="tools"

DEPEND="
	dev-lang/go
	app-misc/godep
"
RDEPEND="${DEPEND}"

DOCS=( README.md CONTRIBUTORS LICENSE CONTRIBUTING.md )

export GOPATH="${S}"

GO_PN="github.com/calmh/${PN}"
EGIT_CHECKOUT_DIR="${S}/src/${GO_PN}"
S="${EGIT_CHECKOUT_DIR}"

src_prepare() {
	ewarn "Sorry, but now we'll cut off 'upgrade' command from the syncthing"
	ewarn "We're not a WindowsÂ©Â®â„¢ and we can't trust selfupgrades from precompiled binaries"

#	cd "${EGIT_CHECKOUT_DIR}"
	epatch "${FILESDIR}"/0.8.14_no_bin_upgrades.patch
#	rm "${EGIT_CHECKOUT_DIR}/cmd/syncthing/upgrade.go"
	rm cmd/syncthing/upgrade.go
}

src_compile() {
#	cd ${EGIT_CHECKOUT_DIR}

	# XXX: All the stuff below needs for "-version" command to show actual info
	local version="$(git describe --always)";
	local date="$(git show -s --format=%ct)";
	local user="$(whoami)"
	local host="$(hostname)"; host="${host%%.*}";
	local lf="-w -X main.Version ${version} -X main.BuildStamp ${date} -X main.BuildUser ${user} -X main.BuildHost ${host}"

#	go vet ./...
	godep go build -ldflags "${lf}" ./cmd/syncthing

	use tools && (
		godep go build ./cmd/stcli
		godep go build ./cmd/stpidx
		godep go build ./discover/cmd/discosrv
	)
}

src_install() {
#	cd ${EGIT_CHECKOUT_DIR}

	dobin syncthing
	use tools && dobin stcli stpidx discosrv
	base_src_install_docs
}
