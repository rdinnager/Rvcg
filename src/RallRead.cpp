#include "typedefImport.h"
#include <wrap/io_trimesh/import.h>
#include <wrap/io_trimesh/export.h>
#include <wrap/io_trimesh/export_ply.h>
#include <vcg/container/simple_temporary_data.h>
#include <string.h>
#include <Rcpp.h>  

using namespace Rcpp;

RcppExport SEXP RallRead(SEXP filename_, SEXP updateNormals_, SEXP colorread_, SEXP clean_) 
{
  std::string str = Rcpp::as<std::string>(filename_);
  const char *filename = str.c_str();
  bool updateNormals = as<bool>(updateNormals_);
  bool colorread = as<bool>(colorread_);
  bool clean = as<bool>(clean_);
  MyMeshImport m;
  int err2 = tri::io::Importer<MyMeshImport>::Open(m,filename);
  if (err2) {
    return wrap(1);
  } else { 
    if (m.fn == 0)
      updateNormals = false;
    SimpleTempData<MyMeshImport::VertContainer,int> indices(m.vert);
    if (updateNormals) {
      tri::UpdateNormal<MyMeshImport>::PerVertexNormalized(m);
      //tri::UpdateNormal<MyMeshImport>::NormalizePerVertex(m);
    }
    if (clean) {
      int dup = tri::Clean<MyMeshImport>::RemoveDuplicateVertex(m);
      int dupface = tri::Clean<MyMeshImport>::RemoveDuplicateFace(m);
      int unref =  tri::Clean<MyMeshImport>::RemoveUnreferencedVertex(m);
      vcg::tri::Allocator< MyMeshImport >::CompactVertexVector(m);
      vcg::tri::Allocator< MyMeshImport >::CompactFaceVector(m);
      if (dup > 0 || unref > 0 || dupface > 0)
	Rprintf("Removed %i duplicate %i unreferenced vertices and %i duplicate faces\n",dup,unref,dupface);
    }  
    NumericVector vb(3*m.vn);
    std::vector<float> texvec;
    std::vector<int> colvec;
    if (colorread)
      colvec.resize(3*m.vn);
    if (colorread)
      texvec.resize(2*m.vn);
    IntegerVector it(3*m.fn);
    std::vector<double> normals;
    if (updateNormals)
      normals.resize(3*m.vn);
   
    VertexIterator vi=m.vert.begin();
    for (int i=0;  i < m.vn; i++) {
      vb(i*3) = (*vi).P()[0];
      vb(i*3+1) = (*vi).P()[1];
      vb(i*3+2) = (*vi).P()[2];
      indices[vi] = i;
      if (updateNormals) {
	normals[i*3] = (*vi).N()[0];
	normals[i*3+1] = (*vi).N()[1];
	normals[i*3+2] = (*vi).N()[2];
      }
      if (colorread) {
	colvec[i*3] = (*vi).C()[0];
	colvec[i*3+1] = (*vi).C()[1];
	colvec[i*3+2] = (*vi).C()[2];
	texvec[i*2] = (*vi).T().U();
	texvec[i*2+1] = (*vi).T().V();
	

      }
    
      ++vi;
    }
    FacePointer fp;
    int vv[3];
    FaceIterator fi=m.face.begin();
    if (m.fn > 0) {
      for (int i=0; i < m.fn;i++) {
	fp=&(*fi);
	if( ! fp->IsD() ) {
	  vv[0]=indices[fp->cV(0)];
	  vv[1]=indices[fp->cV(1)];
	  vv[2]=indices[fp->cV(2)];
	  it(i*3)=vv[0];
	  it(i*3+1)=vv[1];
	  it(i*3+2)=vv[2];
	  ++fi;
	}
      }
    }
    //return wrap(vb);
    return List::create(Named("vb") = vb, 
			Named("it") = it,
			Named("normals") = normals,
			Named("colors") = colvec,
			Named("texcoord") = texvec
			);
  }
 }
