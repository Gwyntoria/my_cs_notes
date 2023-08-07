# ISP调试

## 相关内容

线性模式下，影响图像质量的维度主要有：

1. 亮度
2. 清晰度和噪声
3. 通透性
4. 色彩还原

## 相关模块

### 亮度

1. 自动曝光(AE)
2. DRC
3. Mesh Shading

### 清晰度和噪声

1. Demosaic
2. 3DNR前Sharpen
3. 3DNR后Sharpen(Hi3516CV500/Hi3516EV200/Hi3516EV300/ Hi3518EV300 不支持)
4. NR
5. DPC
6. 3DNR

### 通透性

1. Gamma
2. LDCI
3. Dehaze
4. DRC

### 色彩

1. AWB
2. CCM
3. CLUT(Hi3516EV200/Hi3516EV300/Hi3518EV300不支持)
4. CA(Hi3559V200/Hi3556V200 不支持)

### 需要校准的客观参数

1. BLC
2. LSC
3. Noise profile
4. Gamma
5. CCM
6. AWB
7. Tone Mapping
8. CAC （色差校正）

## AE 基本原理

### 自动曝光与亮度的区别

通常，曝光值的计算公式为：$Exposure = ISO \times Aperture \times Exposure Time$

而图像的成像亮度，则还包括AE阶段之后的Gamma、Tone mapping、Multi Frame HDR……图像处理阶段

## HLC Attribute

### 功能描述

HLC（High Light Cover）高光遮蔽模块，是用于将图像中亮度最高的区域（一般都是
夜晚场景的车灯或者路灯等光源）拉灰，以减少类似于车灯等高亮光源对人眼的刺
激。

Hi3559AV100/Hi3559V200/Hi3516EV200/Hi3516EV300 不支持此模块。

### 参数说明

| 参数名       | 说明                     |
| ------------ | ------------------------ |
| `Enable`     | HLC 高光遮蔽功能是否开启 |
| `LumaThr`    | 高光遮蔽的阈值           |
| `LumaTarget` | 高光遮蔽拉灰的目标值     |

### 调试步骤

1. 先将`LumaTarget`的值调至0，将高光抑制表现到最大。（表现在强光源被显示黑色）
2. 再调节`LumaThr`，调整需要抑制的光强阈值（表现在黑色高光部分的范围）
3. 重新调整`LumaTarget`，将光强度达到`LumaThr`的光，调整到光强度`LumaTarget`（事实上`LumaTarget`的值可以高于`LumaThr`）



