Name:           cmake-extra-utils
Version:        0.0.0
Release:        %{autorelease}
Summary:        Helpful cmake scripts

License:        GPL-3.0-or-later
URL:            https://github.com/LecrisUT/CMakeExtraUtils
Source:         https://github.com/LecrisUT/CMakeExtraUtils/archive/refs/tags/v%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  cmake
Requires:       cmake

%description
A collection of helpful cmake scripts


%prep
%autosetup -n CMakeExtraUtils-%{version}


%build
%cmake
%cmake_build


%install
%cmake_install


%check
%ctest


%files
%license LICENSE
%doc README.md
%{_datadir}/cmake/CMakeExtraUtils


%changelog
%autochangelog
