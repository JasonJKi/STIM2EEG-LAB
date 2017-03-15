#!/bin/bash

#define the variables we need
PROJECT="LabRecorder"

#this is the path to qmake -- sometimes it is /usr/bin
#or in /opt/local/bin -- which ever directory it is in, put it here:
QMAKEPATH="/usr/local/bin"

#add extra paths and libraries here
includepath="../../LSL/liblsl/include /usr/local/include /usr/local/Cellar/qt/4.8.6/lib/QtNetwork.framework/Versions/4/Headers"
libpath="-L./OSX -L/usr/local/Cellar/boost/1.59.0/lib/ -L/usr/local/lib -L./"
libs="-shared -llsl64 -static -lboost_thread-mt -lboost_system-mt -lboost_chrono-mt -lboost_iostreams-mt -lboost_exception-mt -lboost_filesystem-mt"


echo "adjusting runtime library paths"

#do the same for the local copy of liblsl 
install_name_tool -id "@executable_path/../Resources/liblsl64.dylib" ./liblsl64.dylib
install_name_tool -id "@executable_path/../Resources/liblsl32.dylib" ./liblsl32.dylib

echo "exporting LDFLAGS"

#check if the app is already build
if [ -e "$PROJECT.app" ] 
  then 
    rm -r $PROJECT.app
    echo "Removing Previous Build..."
fi 


#go up to the project root
echo "switching to parent directory"
cd ../

# updating automatically generated files
echo "updating automatically generated files"
$QMAKEPATH/uic mainwindow.ui -o ui_mainwindow.h
$QMAKEPATH/moc mainwindow.h -o moc_mainwindow.cpp

#there might be a dangling app here as well, if so remove it
#check if the app is already build
if [ -e "$PROJECT.app" ] 
  then 
    if [-e "$PROJECT.app/Contents/MacOS/pupilpro_config.cfg"]
    then
	rm $PROJECT.app/Contents/MacOS/pupilpro_config.cfg
    fi
    rm -r $PROJECT.app
    echo "Removing Previous Build..."
fi 


#invoke qmake to make a project file
echo "creating project file"
$QMAKEPATH/qmake -project

#shove in our library includes
echo 'INCLUDEPATH +=' $includepath >> $PROJECT.pro 
echo 'LIBS +=' $libpath $libs >> $PROJECT.pro 
echo 'CXXFLAGS += -m64' >> $PROJECT.pro 
#generate the makefile
$QMAKEPATH/qmake -spec macx-g++ $PROJECT.pro

#tweak the maxosx-version-min
echo 'adjusting minimum osx version to ' $minosx
sed -i -e 's/min=10.5/min=10.9\ -m64/g' Makefile

#make it
echo
echo "building app..."
make
cd OSX

echo "cleaning up..."
#cleanup
rm ../*.o
#rm ../Makefile
#rm ../$PROJECT.pro
mv ../$PROJECT.app ./

#copy the libraries into the resources folder
cp ./liblsl64.dylib $PROJECT.app/Contents/Resources/
cp ./liblsl32.dylib $PROJECT.app/Contents/Resources/

#copy the config file
cp ../default_config.cfg ./$PROJECT.app/Contents/MacOS/

echo "done"

