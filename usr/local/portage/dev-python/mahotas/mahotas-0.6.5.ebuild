# Copyright 2011 Attila Oláh
# Distributed under the terms of the GNU General Public License v2

EAPI="3"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils


DESCRIPTION="Python Image Processing Library"
HOMEPAGE="http://luispedro.org/software/mahotas http://pypi.python.org/pypi/mahotas"
SRC_URI="http://pypi.python.org/packages/source/m/${PN}/${P}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="+freeimage"

DEPEND="dev-python/numpy
	sci-libs/scipy
	freeimage? ( media-libs/freeimage )"
RDEPEND="${DEPEND}"

python_enable_pyc
