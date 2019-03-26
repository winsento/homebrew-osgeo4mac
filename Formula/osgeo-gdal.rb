class OsgeoGdal < Formula
  desc "GDAL: Geospatial Data Abstraction Library"
  homepage "https://www.gdal.org/"
  url "https://github.com/OSGeo/gdal/archive/v2.4.1.tar.gz"
  sha256 "17f94c0dfbecab2fc2433428766860de3c89c3fba57f5c9aa77749c1824c02aa"

  # revision 1

  head do
    url "https://github.com/OSGeo/gdal.git", :branch => "master"
    depends_on "doxygen" => :build
  end

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "09d2186f7f8c63533697bec5c91525e1b25116d22e7f2498117fdf6640713470" => :mojave
    sha256 "09d2186f7f8c63533697bec5c91525e1b25116d22e7f2498117fdf6640713470" => :high_sierra
    sha256 "fd316043261567dccd72fe994af8b9c08945ca21c8a284a0298be1358e60cd00" => :sierra
  end

  keg_only "older version of gdal is in main tap and installs similar components"

  option "with-postgresql10", "Build with PostgreSQL 10 client"

  depends_on "pkg-config"
  depends_on "libiconv"
  depends_on "expat"
  depends_on "zlib"
  depends_on "qhull"
  depends_on "curl"
  depends_on "libpng"
  depends_on "freexl"
  depends_on "geos"
  depends_on "jpeg"
  depends_on "json-c"
  depends_on "giflib"
  depends_on "libgeotiff"
  depends_on "libpq"
  depends_on "sqlite" # To ensure compatibility with SpatiaLite.
  depends_on "pcre" # for REGEXP operator in SQLite/Spatialite driver
  depends_on "libspatialite"
  depends_on "libtiff"
  depends_on "osgeo-proj"
  depends_on "numpy"
  depends_on "armadillo"
  depends_on "sfcgal"
  depends_on :java => ["1.8", :build]
  depends_on "ant"
  depends_on "swig"
  depends_on "mdbtools"
  depends_on "libzip"
  depends_on "openssl"
  depends_on "cryptopp"
  depends_on "osgeo-libkml"

  # Raster libraries
  depends_on "osgeo-netcdf" # Also brings in HDF5
  depends_on "osgeo-hdf4"
  depends_on "hdf5"
  depends_on "cfitsio"
  depends_on "epsilon"
  depends_on "jasper"
  depends_on "libdap"
  depends_on "libxml2"
  depends_on "openjpeg"
  depends_on "zstd"
  depends_on "webp"

  # Vector libraries
  depends_on "unixodbc" # OS X version is not complete enough
  depends_on "xerces-c"

  # Other libraries
  depends_on "xz" # get liblzma compression algorithm library from XZutils

  # depends_on "charls" # cask

  if build.with?("postgresql10")
    depends_on "postgresql@10"
  else
    depends_on "osgeo-postgresql"
  end

  # - Base configuration
  # - GDAL native backends
  # - Supported backends: optional Homebrew packages supporting additional formats.
  # - Unsupported backends: The libraries are either proprietary, not available for public
  #   download or have no stable version in the Homebrew core that is
  #   compatible with GDAL. Interested users will have to install such software
  #   manually and most likely have to tweak the install routine.
  # - GRASS backend explicitly disabled.  Creates a chicken-and-egg problem.
  #   Should be installed separately after GRASS installation using the
  #   official GDAL GRASS plugin.
  # - Python is installed manually to ensure everything is properly sandboxed
  # - All PDF driver functionality moved to gdal2-pdf plugin
  #   Older pdfium (for gdal driver) is still built against libstdc++ and
  #   causes the base build to be built like that as well.
  #   See: https://github.com/rouault/pdfium
  # - Database support

  def configure_args
    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--with-local=#{prefix}",
      "--with-dods-root=#{HOMEBREW_PREFIX}",
      "--with-libtool",
      "--with-bsb",
      "--with-grib",
      "--with-pam",
      "--with-opencl",
      "--with-pcre",
      "--with-threads=yes",
      "--with-java=yes",
      "--with-liblzma=yes",
      "--with-pcidsk=internal",
      "--with-pcraster=internal",
      "--with-qhull=internal",
      "--with-libz=#{Formula["libzip"].opt_prefix}",
      "--with-png=#{Formula["libpng"].opt_prefix}",
      "--with-libtiff=#{Formula["libtiff"].opt_prefix}",
      "--with-geotiff=#{Formula["libgeotiff"].opt_prefix}",
      "--with-jpeg=#{Formula["jpeg"].opt_prefix}",
      "--with-gif=#{Formula["giflib"].opt_prefix}",
      "--with-libjson-c=#{Formula["json-c"].opt_prefix}",
      "--with-libiconv-prefix=#{Formula["libiconv"].opt_prefix}",
      "--with-proj=#{Formula["osgeo-proj"].opt_prefix}",
      "--with-zstd=#{Formula["zstd"].opt_prefix}",
      "--with-cfitsio=#{Formula["cfitsio"].opt_prefix}",
      "--with-hdf4=#{Formula["osgeo-hdf4"].opt_prefix}",
      "--with-hdf5=#{Formula["hdf5"].opt_prefix}",
      "--with-netcdf=#{Formula["osgeo-netcdf"].opt_prefix}",
      "--with-jasper=#{Formula["jasper"].opt_prefix}",
      "--with-openjpeg=#{Formula["openjpeg"].opt_prefix}",
      "--with-expat=#{Formula["expat"].opt_prefix}",
      "--with-odbc=#{Formula["unixodbc"].opt_prefix}",
      "--with-curl=#{Formula["curl"].opt_bin}/curl-config",
      "--with-xml2=#{Formula["libxml2"].opt_bin}/xml2-config",
      "--with-spatialite=#{Formula["libspatialite"].opt_prefix}",
      "--with-sqlite3=#{Formula["sqlite"].opt_prefix}",
      "--with-webp=#{Formula["webp"].opt_prefix}",
      "--with-geos=#{Formula["geos"].opt_bin}/geos-config",
      "--with-freexl=#{Formula["freexl"].opt_prefix}",
      "--with-xerces=#{Formula["xerces-c"].opt_prefix}",
      "--with-libkml=#{Formula["osgeo-libkml"].opt_prefix}",
      "--with-epsilon=#{Formula["epsilon"].opt_prefix}",
      "--with-sfcgal=#{Formula["sfcgal"].opt_bin}/sfcgal-config",
      "--with-armadillo=#{Formula["armadillo"].opt_prefix}",
      "--with-cryptopp=yes",
      "--with-crypto=yes",
      "--with-grass=no",
      "--with-libgrass=no",
      "--with-fme=no",
      "--with-ecw=no",
      "--with-kakadu=no",
      "--with-mrsid=no",
      "--with-jp2mrsid=no",
      "--with-msg=no",
      "--with-oci=no",
      "--with-ingres=no",
      "--with-idb=no",
      "--with-sde=no",
      "--with-perl=no",
      "--with-python=no",
      "--with-gta=no",
      "--with-ogdi=no",
      "--with-sosi=no",
      "--with-mongocxx=no",
      "--with-fgdb=no",
      "--with-mrsid_lidar=no",
      "--with-gnm",
      "--with-mysql=no",
      "--with-poppler=no",
      "--with-podofo=no",
      "--with-pdfium=no",
      "--with-kea=no",
      "--with-teigha=no",
      "--with-mdb=no",
      "--with-dds=no",
      "--with-hdfs=no",
      "--with-j2lura=no",
      "--with-rasterlite2=no",
      "--with-rasdaman=no",
      # "--with-charls",

      # "--with-boost-lib-path",
      # "--with-mongocxxv3",
      # "--with-teigha-plt",
      # "--with-jvm-lib",
      # "--with-jvm-lib-add-rpath",
      # "--with-cpp14",
      # "--with-pic",
      # "--with-aix-soname",
      # "--with-gnu-ld",
      # "--with-sysroot",
      # "--with-unix-stdio-64",
      # "--with-sse",
      # "--with-ssse3",
      # "--with-avx",
      # "--with-hide-internal-symbols",
      # "--with-rename-internal-libtiff-symbols",
      # "--with-rename-internal-libgeotiff-symbols",
      # "--with-rename-internal-shapelib-symbols",
      # "--with-gnu-ld",
      # "--with-spatialite-soname",
      # "--with-sde-version",
      # "--with-gdal-ver",
      # "--with-macosx-framework",
      # "--with-null",
      # "--with-podofo-lib",
      # "--with-podofo-extra-lib-for-test",
      # "--with-pdfium-lib",
      # "--with-pdfium-extra-lib-for-test",
      # "--with-xerces-inc",
      # "--with-xerces-lib",
      # "--with-expat-inc",
      # "--with-expat-lib",
      # "--with-libkml-inc",
      # "--with-libkml-lib",
      # "--with-oci-include",
      # "--with-oci-lib",
      # "--with-opencl-include",
      # "--with-opencl-lib",

      "--without-jpeg12", # Needs specially configured JPEG and TIFF libraries
      # "--without-lerc",
      # "--without-libtool",
      # "--without-ld-shared",
      # "--without-libiconv-prefix",
      # "--without-pam",
      # "--without-php",
      # "--without-dwgdirect",
      # "--without-ruby",
    ]
    args
  end

  def plugins_subdirectory
    gdal_ver_list = version.to_s.split(".")
    "gdalplugins/#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def install
    # Temporary fix for Xcode/CLT 9.0.x issue of missing header files
    # See: https://github.com/OSGeo/homebrew-osgeo4mac/issues/276
    # Work around "error: no member named 'signbit' in the global namespace"
    if DevelopmentTools.clang_build_version >= 900
      ENV.delete "SDKROOT"
      ENV.delete "HOMEBREW_SDKROOT"
    end

    # Linking flags for SQLite are not added at a critical moment when the GDAL
    # library is being assembled. This causes the build to fail due to missing
    # symbols. Also, ensure Homebrew SQLite is used so that Spatialite is
    # functional
    # Fortunately, this can be remedied using LDFLAGS
    sqlite = Formula["sqlite"]
    ENV.append "LDFLAGS", "-L#{sqlite.opt_lib} -lsqlite3"
    ENV.append "CFLAGS", "-I#{sqlite.opt_include}"

    # Reset ARCHFLAGS to match how we build
    ENV["ARCHFLAGS"] = "-arch #{MacOS.preferred_arch}"

    chdir "gdal" do
      # GDAL looks for the renamed hdf4 library, which is an artifact of old builds, so we need to repoint it
      inreplace "configure", "-ldf", "-lhdf"

      # Fix hardcoded mandir: http://trac.osgeo.org/gdal/ticket/5092
      inreplace "configure", %r[^mandir='\$\{prefix\}/man'$], ""

      # These libs are statically linked in libkml-dev and libkml formula
      inreplace "configure", " -lminizip -luriparser", ""

      # All PDF driver functionality moved to gdal2-pdf plugin,
      # so nix default internal-built PDF w+ driver, which keeps plugin from loading.
      # Just using --enable-pdf-plugin isn't enough (we don't want the plugin built here)
      inreplace "GDALmake.opt.in", "PDF_PLUGIN),yes", "PDF_PLUGIN),no"

      args = configure_args

      if build.with?("postgresql10")
        args << "--with-pg=#{Formula["postgresql@10"].opt_bin}/pg_config"
      else
        args << "--with-pg=#{Formula["osgeo-postgresql"].opt_bin}/pg_config"
      end

      system "./configure", *args
      system "make"
      system "make", "install"

      # Add GNM headers for gdal2-python swig wrapping
      include.install Dir["gnm/**/*.h"]

      cd "swig/java" do
        inreplace "java.opt", "linux", "darwin"
        inreplace "java.opt", "#JAVA_HOME = /usr/lib/jvm/java-6-openjdk/", "JAVA_HOME=#{ENV["JAVA_HOME"]}"
        system "make"
        system "make", "install"

        # Install the jar that complements the native JNI bindings
        lib.install "gdal.jar"
      end

      system "make", "man" if build.head?
      # Force man installation dir: https://trac.osgeo.org/gdal/ticket/5092
      system "make", "install-man", "INST_MAN=#{man}"
      # Clean up any stray doxygen files
      system "make", "install-man"
      # Clean up any stray doxygen files.
      Dir.glob("#{bin}/*.dox") { |p| rm p }
    end
  end

  def post_install
    # Create versioned plugins path for other formulae
    (HOMEBREW_PREFIX/"lib/#{plugins_subdirectory}").mkpath
  end

  def caveats
    s = <<~EOS
      Plugins for this version of GDAL/OGR, generated by other formulae, should
      be symlinked to the following directory:

        #{HOMEBREW_PREFIX}/lib/#{plugins_subdirectory}

      You may need to set the following enviroment variable:

        export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins

      PYTHON BINDINGS are now built in a separate formula: osgeo-gdal-python
    EOS
    s
  end

  test do
    # basic tests to see if third-party dylibs are loading OK
    system "#{bin}/gdalinfo", "--formats"
    system "#{bin}/ogrinfo", "--formats"
  end
end
