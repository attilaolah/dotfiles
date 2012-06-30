# Copyright 2011 Attila Oláh
# Distributed under the terms of the GNU General Public License v2

EAPI="3"

inherit eutils

DESCRIPTION="Equinox GTK engine and themes"
HOMEPAGE="http://gnome-look.org/content/show.php/Equinox+GTK+Engine?content=121881"
SRC_URI="http://gnome-look.org/CONTENT/content-files/121881-${P}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="+animation"

DEPEND="x11-libs/gtk+:2"
RDEPEND="${DEPEND}"

src_configure() {
	econf \
		$(use_enable animation animation)
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-glib-2.32.patch"
}
