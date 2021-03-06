class OsgeoQscintilla2 < Formula
  desc "Port to Qt of the Scintilla editing component"
  homepage "https://www.riverbankcomputing.com/software/qscintilla/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/QScintilla/QScintilla_gpl-2.11.1.tar.gz"
  sha256 "dae54d19e43dba5a3f98ac084fc0bcfa6fb713fa851f1783a01404397fd722f5"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "e52e5650b1dfeae0b011b5bfcdff7bad945bf52fd549f8fbb12505d97a70674d" => :mojave
    sha256 "e52e5650b1dfeae0b011b5bfcdff7bad945bf52fd549f8fbb12505d97a70674d" => :high_sierra
    sha256 "9c4d91781a8670fa6491b7898be72767fba592b853e873596f5dfdd82b640ac5" => :sierra
  end

  revision 2

  depends_on "python"
  depends_on "python@2"
  depends_on "qt"
  depends_on "osgeo-sip"
  depends_on "osgeo-pyqt"

  def install
    spec = (ENV.compiler == :clang && MacOS.version >= :mavericks) ? "macx-clang" : "macx-g++"
    args = %W[-config release -spec #{spec}]

    cd "Qt4Qt5" do
      inreplace "qscintilla.pro" do |s|
        s.gsub! "$$[QT_INSTALL_LIBS]", lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
        s.gsub! "$$[QT_INSTALL_TRANSLATIONS]", prefix/"trans"
        s.gsub! "$$[QT_INSTALL_DATA]", prefix/"data"
        s.gsub! "$$[QT_HOST_DATA]", prefix/"data"
      end

      inreplace "features/qscintilla2.prf" do |s|
        s.gsub! "$$[QT_INSTALL_LIBS]", lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
      end

      system "#{Formula["qt"].bin}/qmake", "qscintilla.pro", *args
      system "make"
      system "make", "install"
    end

    # Add qscintilla2 features search path, since it is not installed in Qt keg's mkspecs/features/
    ENV["QMAKEFEATURES"] = prefix/"data/mkspecs/features"

    cd "Python" do
      (share/"sip/PyQt5/Qsci").mkpath
      ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python3"].opt_bin}/python3"].each do |python|
        version = Language::Python.major_minor_version python
        system python, "configure.py", "-o", lib, "-n", include,
                       "--apidir=#{prefix}/qsci",
                       "--destdir=#{lib}/python#{version}/site-packages/PyQt5",
                       "--stubsdir=#{lib}/python#{version}/site-packages/PyQt5",
                       "--qsci-sipdir=#{share}/sip/PyQt5",
                       "--qsci-incdir=#{include}",
                       "--qsci-libdir=#{lib}",
                       "--pyqt=PyQt5",
                       "--pyqt-sipdir=#{Formula["osgeo-pyqt"].opt_share}/sip/PyQt5",
                       "--sip-incdir=#{Formula["osgeo-sip"].opt_include}",
                       "--spec=#{spec}",
                       "--no-dist-info",
                       "--verbose"
        system "make"
        system "make", "install"
        system "make", "clean"
      end
        (share/"sip/PyQt5/Qsci").install Dir["sip/*.sip"]
    end
  end

  test do
    (testpath/"test.py").write <<~EOS
      import PyQt5.Qsci
      assert("QsciLexer" in dir(PyQt5.Qsci))
    EOS

    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      version = Language::Python.major_minor_version python
      ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
      system python, "test.py"
    end
  end
end
