# `sample_venc.c`代码结构

## `sample_venc.c`基本架构

- `sample_venc.c`中的`main`函数调用已在`sample_venc.c`中的定义的功能函数
- `sample_venc.c`中的功能函数调用`common`文件夹(包含**通用性主体函数**)中的功能函数
- `common`中的功能函数再调用`Media Process Platform`中的`API`
- `API`来自`sdk`提供的`.ko`文件，即官方编译好的**动态库文件**
- 调用`API`的头文件位于`MPP`下的`include`文件夹中

## `main --> H265_H264`

```c
main 
    SAMPLE_VENC_Usage() /*sample的用法*/
    switch(u32Index)
        SAMPLE_VENC_H265_H264() // 编码H264，265
            SAMPLE_COMM_SYS_GetPicSize() // 获得通道图片大小
            SAMPLE_COMM_VI_GetSensorInfo() // 获取sensor信息（分辨率、帧率……）
            SAMPLE_VENC_CheckSensor() // 检查从sensor获取的信息也配置信息是否匹配
            	SAMPLE_VENC_ModifyResolution() // if Hifailure run this (获取的Sensor信息和配置的信息不同时，修改配置信息)
                	SAMPLE_COMM_VI_GetSizeBySensor() // Get enSize by diffrent sensor
                	SAMPLE_COMM_SYS_GetPicSize() // get picture size(w*h), according enPicSize
            SAMPLE_VENC_VI_Init() // VI初始化
                SAMPLE_VENC_SYS_Init() // 系统初始化
                    memset(&stVbConf, 0, sizeof(VB_CONFIG_S)) // 缓存池内存清0
                    SAMPLE_COMM_VI_GetSizeBySensor() // 从sensor类型得到图像数据是1080p，720p之类
                    SAMPLE_COMM_SYS_GetPicSize() // 从1080P，720p得到图像的宽与高
                    COMMON_GetPicBufferSize() // 计算缓存块大小
                    if(0 == u32SupplementConfig)
                        SAMPLE_COMM_SYS_Init() 
                            HI_MPI_SYS_Exit() // 去初始化2
                            HI_MPI_VB_Exit() // VB去初始化
                            HI_MPI_VB_SetConfig() // VB set
                            HI_MPI_VB_Init() // VB init
                            HI_MPI_SYS_Init() // mpp init
                        SAMPLE_COMM_SYS_InitWithVbSupplement()
                            HI_MPI_SYS_Exit() // 去初始化
                            HI_MPI_VB_Exit() // VB去初始化
                            HI_MPI_VB_SetConfig()
                            HI_MPI_VB_SetSupplementConfig() // 设置VB内存的附加信息
                            HI_MPI_VB_Init()
                            HI_MPI_SYS_Init()
            SAMPLE_VENC_VPSS_Init()
                SAMPLE_COMM_VI_GetSizeBySensor() // 从sensor类型得到图像数据是1080p，720p之类
                SAMPLE_COMM_SYS_GetPicSize() // 从1080P，720p得到图像的宽与高
                SAMPLE_COMM_VPSS_Start() // 
                    HI_MPI_VPSS_CreateGrp()
                    HI_MPI_VPSS_SetChnAttr()
                    HI_MPI_VPSS_StartGrp()
            SAMPLE_COMM_VI_Bind_VPSS() // 可直接调用，海思good
                HI_MPI_SYS_Bind()
 
            // start stream venc
            SAMPLE_VENC_GetRcMode() // get cbr etc
            SAMPLE_VENC_GetGopMode() // get NORMALP etc
            SAMPLE_COMM_VENC_GetGopAttr() // 配置GOP if failure goto EXIT_VI_VPSS_UNBIND
 
            /***encode h.265 **/
            SAMPLE_COMM_VENC_Start() // if failure goto EXIT_VI_VPSS_UNBIND
                SAMPLE_COMM_VENC_Creat()
                    SAMPLE_COMM_SYS_GetPicSize()
                    SAMPLE_COMM_VI_GetSensorInfo() // 获取sensor数据，配置chn，dev等
                    SAMPLE_COMM_VI_GetFrameRateBySensor() // get information from sensor and control framerate
                    HI_MPI_VENC_CreateChn()
                    SAMPLE_COMM_VENC_CloseReEncode()
            SAMPLE_COMM_VPSS_Bind_VENC() // if failure goto EXIT_VENC_H265_STOP
 
            /***encode h.264 **/
            SAMPLE_COMM_VENC_Start() // if failure goto EXIT_VI_VPSS_UNBIND
            SAMPLE_COMM_VPSS_Bind_VENC() // if failure goto EXIT_VENC_H264_STOP
 
            //stream save process
            SAMPLE_COMM_VENC_StartGetStream()
                pthread_create(&gs_VencPid, 0, SAMPLE_COMM_VENC_GetVencStreamProc, (HI_VOID*)&gs_stPara); // 创建线程
                   SAMPLE_COMM_VENC_GetVencStreamProc() // this has 5 steps and if failure goto EXIT_VENC_H264_UnBind
 
                SAMPLE_COMM_VENC_StopGetStream() // exit
            EXIT_VENC_H264_UnBind:
                SAMPLE_COMM_VPSS_UnBind_VENC(VpssGrp,VpssChn[1],VencChn[1]);
            EXIT_VENC_H264_STOP:
                SAMPLE_COMM_VENC_Stop(VencChn[1]);
            EXIT_VENC_H265_UnBind:
                SAMPLE_COMM_VPSS_UnBind_VENC(VpssGrp,VpssChn[0],VencChn[0]);
            EXIT_VENC_H265_STOP:
                SAMPLE_COMM_VENC_Stop(VencChn[0]);
            EXIT_VI_VPSS_UNBIND:
                SAMPLE_COMM_VI_UnBind_VPSS(ViPipe,ViChn,VpssGrp);
            EXIT_VPSS_STOP:
                SAMPLE_COMM_VPSS_Stop(VpssGrp,abChnEnable);
            EXIT_VI_STOP:
                SAMPLE_COMM_VI_StopVi(&stViConfig);
                SAMPLE_COMM_SYS_Exit();
 
        SAMPLE_VENC_LOW_DELAY() // 低延时
        SAMPLE_VENC_Qpmap()
        SAMPLE_VENC_IntraRefresh()
        SAMPLE_VENC_ROIBG()
        SAMPLE_VENC_DeBreathEffect()
        SAMPLE_VENC_SVC_H264()
        SAMPLE_VENC_MJPEG_JPEG()
        SAMPLE_VENC_Usage()
```

## `main --> Low_Delay`

```c
HI_S32 SAMPLE_VENC_LOW_DELAY()
    HI_S32 SAMPLE_COMM_SYS_GetPicSize() // get picture size(w*h), according enPicSize
    HI_VOID SAMPLE_COMM_VI_GetSensorInfo() // Get sensor information
    HI_S32 SAMPLE_VENC_CheckSensor() // Check sensor information
    	HI_S32 SAMPLE_VENC_ModifyResolution() // 
    		HI_S32 SAMPLE_COMM_VI_GetSizeBySensor()
    		HI_S32 SAMPLE_COMM_SYS_GetPicSize()
    HI_S32 SAMPLE_VENC_VI_Init() 	// Initialize VI
    	HI_S32 SAMPLE_VENC_SYS_Init()
    		HI_S32 SAMPLE_COMM_VI_GetSizeBySensor()
    		HI_S32 SAMPLE_COMM_SYS_GetPicSize()
    		static inline HI_U32 COMMON_GetPicBufferSize() 
    		HI_S32 SAMPLE_COMM_SYS_Init()
    	HI_S32 SAMPLE_COMM_VI_SetParam()
    		HI_S32 HI_MPI_SYS_GetVIVPSSMode()
    		if ((pstViInfo->stPipeInfo.bMultiPipe == HI_TRUE)|| (VI_OFFLINE_VPSS_ONLINE == pstViInfo->stPipeInfo.enMastPipeMode))
    			HI_S32 SAMPLE_COMM_VI_UpdateVIVPSSMode()
    		HI_S32 HI_MPI_SYS_SetVIVPSSMode()
   	 	HI_S32 SAMPLE_COMM_VI_GetFrameRateBySensor()
    	HI_S32 HI_MPI_ISP_SetCtrlParam()
    	HI_S32 SAMPLE_COMM_VI_StartVi()
            HI_S32 SAMPLE_COMM_VI_StartMIPI()
                HI_U32 SAMPLE_COMM_VI_GetMipiLaneDivideMode()
                HI_S32 SAMPLE_COMM_VI_SetMipiHsMode()
                HI_S32 SAMPLE_COMM_VI_EnableMipiClock()
                HI_S32 SAMPLE_COMM_VI_ResetMipi()
                HI_S32 SAMPLE_COMM_VI_EnableSensorClock()
                HI_S32 SAMPLE_COMM_VI_ResetSensor()
                HI_S32 SAMPLE_COMM_VI_SetMipiAttr()
                HI_S32 SAMPLE_COMM_VI_UnresetMipi()
                HI_S32 SAMPLE_COMM_VI_UnresetSensor()
            HI_S32 SAMPLE_COMM_VI_SetParam()
                HI_S32 HI_MPI_SYS_GetVIVPSSMode()
                if ((pstViInfo->stPipeInfo.bMultiPipe == HI_TRUE)|| (VI_OFFLINE_VPSS_ONLINE == pstViInfo->stPipeInfo.enMastPipeMode))
                    HI_S32 SAMPLE_COMM_VI_UpdateVIVPSSMode()
            HI_S32 SAMPLE_COMM_VI_CreateVi()
            HI_S32 SAMPLE_COMM_VI_CreateIsp()
            if (s32Ret != HI_SUCCESS)
            	HI_S32 SAMPLE_COMM_VI_DestroyVi()
    HI_S32 SAMPLE_VENC_VPSS_Init() 	// Initialize VPSS
    HI_S32 HI_MPI_VPSS_SetLowDelayAttr() // Set low delay attribute
    HI_S32 SAMPLE_COMM_VI_Bind_VPSS() // Bind VI and VPSS
    
    // Get RcMode and GopMode
    SAMPLE_RC_E SAMPLE_VENC_GetRcMode()
    VENC_GOP_MODE_E SAMPLE_VENC_GetGopMode()
    
    HI_S32 SAMPLE_COMM_VENC_GetGopAttr() // Get Gop Attribute
    HI_S32 SAMPLE_COMM_VENC_Start() // Start venc stream mode. note: rate control parameter need adjust, according your case.
    HI_S32 SAMPLE_COMM_VPSS_Bind_VENC() // Bind VPSS and VENC
    HI_S32 SAMPLE_COMM_VENC_StartGetStream() // Stream save process
    HI_S32 SAMPLE_COMM_VENC_StopGetStream() // Exit process
```

