# Copyright 2011 Attila Olah
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="An implementation of the General Number Field Sieve written in C++"
HOMEPAGE="http://www.pgnfs.org/"
SRC_URI="http://www.pgnfs.org/SRC/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sci-mathematics/ginac
	dev-libs/ntl"
DEPEND="${RDEPEND}"
