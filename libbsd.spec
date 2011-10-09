Name:		libbsd
Version:	0.3.0
Release:	1%{?dist}
Summary:	Library providing BSD-compatible functions for portability
URL:		http://libbsd.freedesktop.org/

Source0:	http://libbsd.freedesktop.org/releases/libbsd-%{version}.tar.gz

License:	BSD and ISC and Copyright only and Public Domain
Group:		System Environment/Libraries

%description
libbsd provides useful functions commonly found on BSD systems, and
lacking on others like GNU systems, thus making it easier to port
projects with strong BSD origins, without needing to embed the same
code over and over again on each project.

%package devel
Summary:	Development files for libbsd
Group:		Development/Libraries
Requires:	libbsd = %{version}-%{release}
Requires:	pkgconfig

%description devel
Development files for the libbsd library.

%prep
%setup -q

# fix encoding of flopen.3 man page
for f in src/flopen.3; do
  iconv -f iso8859-1 -t utf-8 $f >$f.conv
  touch -r $f $f.conv
  mv $f.conv $f
done

%build
make CFLAGS="%{optflags}" %{?_smp_mflags} \
     libdir=%{_libdir} \
     usrlibdir=%{_libdir} \
     exec_prefix=%{_prefix}

%install
make libdir=%{_libdir} \
     usrlibdir=%{_libdir} \
     exec_prefix=%{_prefix} \
     DESTDIR=%{buildroot} \
     install

# don't want static library
rm %{buildroot}%{_libdir}/%{name}.a

# Move nlist.h into bsd directory to avoid conflict with elfutils-libelf.
# Anyone that wants that functionality should really used elfutils-libelf
# instead.
mv %{buildroot}%{_includedir}/nlist.h %{buildroot}%{_includedir}/bsd/

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%doc COPYING README TODO ChangeLog
%{_libdir}/%{name}.so.*

%files devel
%{_mandir}/man3/*.3.gz
%{_mandir}/man3/*.3bsd.gz
%{_includedir}/*.h
%{_includedir}/bsd
%{_libdir}/%{name}.so
%{_libdir}/pkgconfig/%{name}.pc
%{_libdir}/pkgconfig/%{name}-overlay.pc

%changelog
* Sat Oct 08 2011 Eric Smith <eric@brouhaha.com> - 0.3.0-1
- Update to latest upstream release.
- Removed Patch0, fixed upstream.
- Removed BuildRoot, clean, defattr.

* Fri Jan 29 2010 Eric Smith <eric@brouhaha.com> - 0.2.0-3
- changes based on review by Sebastian Dziallas

* Fri Jan 29 2010 Eric Smith <eric@brouhaha.com> - 0.2.0-2
- changes based on review comments by Jussi Lehtola and Ralf Corsepious

* Thu Jan 28 2010 Eric Smith <eric@brouhaha.com> - 0.2.0-1
- initial version
