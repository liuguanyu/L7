precision highp float;
attribute vec3 a_Position;
attribute vec4 a_Color;
attribute vec2 a_Uv;
attribute float a_Size;
varying vec4 v_color;
varying vec2 v_uv;
uniform mat4 u_ModelMatrix;
uniform mat4 u_Mvp;
uniform float u_stroke_width : 1;
uniform vec2 u_offsets;

uniform float u_opacity : 1;

varying mat4 styleMappingMat; // 用于将在顶点着色器中计算好的样式值传递给片元

#pragma include "styleMapping"
#pragma include "styleMappingCalOpacity"

#pragma include "projection"
#pragma include "picking"

void main() {
  // cal style mapping - 数据纹理映射部分的计算
  styleMappingMat = mat4(
    0.0, 0.0, 0.0, 0.0, // opacity - strokeOpacity - strokeWidth - empty
    0.0, 0.0, 0.0, 0.0, // strokeR - strokeG - strokeB - strokeA
    0.0, 0.0, 0.0, 0.0, // offsets[0] - offsets[1]
    0.0, 0.0, 0.0, 0.0
  );

  float rowCount = u_cellTypeLayout[0][0];    // 当前的数据纹理有几行
  float columnCount = u_cellTypeLayout[0][1]; // 当看到数据纹理有几列
  float columnWidth = 1.0/columnCount;  // 列宽
  float rowHeight = 1.0/rowCount;       // 行高
  float cellCount = calCellCount(); // opacity - strokeOpacity - strokeWidth - stroke - offsets
  float id = a_vertexId; // 第n个顶点
  float cellCurrentRow = floor(id * cellCount / columnCount) + 1.0; // 起始点在第几行
  float cellCurrentColumn = mod(id * cellCount, columnCount) + 1.0; // 起始点在第几列
  
  // cell 固定顺序 opacity -> strokeOpacity -> strokeWidth -> stroke ... 
  // 按顺序从 cell 中取值、若没有则自动往下取值
  float textureOffset = 0.0; // 在 cell 中取值的偏移量

  vec2 opacityAndOffset = calOpacityAndOffset(cellCurrentRow, cellCurrentColumn, columnCount, textureOffset, columnWidth, rowHeight);
  styleMappingMat[0][0] = opacityAndOffset.r;
  textureOffset = opacityAndOffset.g;

  styleMappingMat[1][0] = a_Size;

  vec2 textrueOffsets = vec2(0.0, 0.0);
  if(hasOffsets()) {
    vec2 valueXPos = nextPos(cellCurrentRow, cellCurrentColumn, columnCount, textureOffset);
    textrueOffsets.r = pos2value(valueXPos, columnWidth, rowHeight); // x
    textureOffset += 1.0;

    vec2 valueYPos = nextPos(cellCurrentRow, cellCurrentColumn, columnCount, textureOffset);
    textrueOffsets.g = pos2value(valueYPos, columnWidth, rowHeight); // x
    textureOffset += 1.0;
  } else {
    textrueOffsets = u_offsets;
  }

  // cal style mapping - 数据纹理映射部分的计算
   v_color = a_Color;
   v_uv = a_Uv;
   vec4 project_pos = project_position(vec4(a_Position, 1.0));
   
  //  vec2 offset = project_pixel(u_offsets);
  vec2 offset = project_pixel(textrueOffsets);

  //  gl_Position = project_common_position_to_clipspace(vec4(vec2(project_pos.xy + offset),project_pos.z, 1.0));

    if(u_CoordinateSystem == COORDINATE_SYSTEM_P20_2) { // gaode2.x
      gl_Position = u_Mvp * vec4(vec2(project_pos.xy + offset),project_pos.z, 1.0);
    } else {
      gl_Position = project_common_position_to_clipspace(vec4(vec2(project_pos.xy + offset),project_pos.z, 1.0));
    }
   gl_PointSize = a_Size * 2.0 * u_DevicePixelRatio;

  setPickingColor(a_PickingColor);

}
