﻿package away3d.tools
{
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;

	use namespace arcane;
	
	/**
	* Class Explode make all vertices and uv's of a mesh unic<code>Explode</code>
	*/
	public class Explode {
		
		private static var _added:uint;
		private static const LIMIT:uint = 64998;

		/**
		*  Apply the explode code to a given ObjectContainer3D.
		* @param	 object		ObjectContainer3D. The target Object3d object.
		*/
		public static function apply(object:ObjectContainer3D):void
		{
			_added = 0;
			parse(object);
		}
		
		/**
		* returns howmany vertices were added during the explode operation.
		*/
		public static function get verticesAdded():int
		{
			return _added;
		}
		
		/**
		* recursive parsing of a container.
		*/
		private static function parse(object:ObjectContainer3D):void
		{
			var child:ObjectContainer3D;
			if(object is Mesh && object.numChildren == 0)
				explode(Mesh(object));
				 
			for(var i:uint = 0;i<object.numChildren;++i){
				child = object.getChildAt(i);
				parse(child);
			}
		}
		
		/**
		* makes all faces unique
		*/
		private static function explode(m:Mesh):void
		{
			var geometry:Geometry = m.geometry;
			var geometries:Vector.<SubGeometry> = geometry.subGeometries;
			var numSubGeoms:int = geometries.length;
			
			var vertices:Vector.<Number>;
			var indices:Vector.<uint>;
			var uvs:Vector.<Number>;
			var normals:Vector.<Number>;
			var tangents:Vector.<Number>;
			 
			var nvertices:Vector.<Number> = new Vector.<Number>();
			var nindices:Vector.<uint> = new Vector.<uint>();
			var nuvs:Vector.<Number> = new Vector.<Number>();
			var nnormals:Vector.<Number> = new Vector.<Number>();
			var ntangents:Vector.<Number> = new Vector.<Number>();
			
			var vectors:Array = [];
			vectors.push([nvertices,nindices,nuvs,nnormals,ntangents]);
			 
			var index:uint;
			var indexuv:uint;
			
			var nIndex:uint = 0;
			var nIndexuv:uint = 0;
			var nIndexind:uint = 0;
			 
			var j : uint;
			var i : uint;
			var vecLength : uint;
			var subGeom:SubGeometry;
			var oriCount:uint = 0;
			var destCount:uint = 0;
			
			for (i = 0; i < numSubGeoms; ++i){
				subGeom = SubGeometry(geometries[i]);
				vertices = subGeom.vertexData;
				indices = subGeom.indexData;
				uvs = subGeom.UVData;
				normals = subGeom.vertexNormalData;
				tangents = subGeom.vertexTangentData;
				vecLength = indices.length;
				oriCount += vertices.length;

				for (j = 0; j < vecLength;++j){
					index = indices[j]*3;
					indexuv = indices[j]*2;
					
					if(nvertices.length+3 > LIMIT){
						destCount+=nvertices.length;
						nIndexind = 0;
						nIndex = 0;
						nIndexuv = 0;
						nvertices = new Vector.<Number>();
						nindices = new Vector.<uint>();
						nuvs =new Vector.<Number>();
						nnormals = new Vector.<Number>();
						ntangents = new Vector.<Number>();
						vectors.push([nvertices,nindices,nuvs, nnormals,ntangents]);
						subGeom = new SubGeometry();
						geometry.addSubGeometry(subGeom);
					}
						
					nindices[nIndexind++] = nvertices.length/3;
					
					nvertices[nIndex] = vertices[index];
					nnormals[nIndex] = normals[index];
					ntangents[nIndex] = tangents[index];
					nIndex++;
					
					index++;
					nvertices[nIndex] = vertices[index];
					nnormals[nIndex] = normals[index];
					ntangents[nIndex] = tangents[index];
					nIndex++;
					
					index++;
					nvertices[nIndex] = vertices[index];
					nnormals[nIndex] = normals[index];
					ntangents[nIndex] = tangents[index];
					nIndex++;
					
					nuvs[nIndexuv++] = uvs[indexuv];
					nuvs[nIndexuv++] = uvs[indexuv+1];
				}
			}
			
			destCount+=nvertices.length;
			_added = (destCount - oriCount)/3;
			
			geometries = geometry.subGeometries;
			numSubGeoms = geometries.length;
			for (i = 0; i < numSubGeoms; ++i){
				subGeom = SubGeometry(geometries[i]);
				subGeom.updateVertexData(vectors[i][0]);
				subGeom.updateIndexData(vectors[i][1]);
				subGeom.updateUVData(vectors[i][2]);
				subGeom.updateVertexNormalData(vectors[i][3]);
				subGeom.updateVertexTangentData(vectors[i][4]); 
			}
			 
			vectors = null;
		}
		 
	}
}