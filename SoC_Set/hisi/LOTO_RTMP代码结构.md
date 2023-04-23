# LOTO_RTMP代码结构

```c
int main(int argc, char *argv[])
    HI_S32 LOTO_RTMP_VA_CLASSIC()
        HI_VOID SAMPLE_COMM_VI_GetSensorInfo()
        HI_S32 LOTO_VENC_CheckSensor()
            HI_S32 ModifyResolution()
            
        HI_S32 LOTO_VENC_VI_Init(SAMPLE_VI_CONFIG_S *pstViConfig, HI_BOOL bLowDelay, HI_U32 u32SupplementConfig)
            HI_S32 LOTO_VENC_SYS_Init(HI_U32 u32SupplementConfig, SAMPLE_SNS_TYPE_E enSnsType)
                HI_S32 SAMPLE_COMM_VI_GetSizeBySensor(SAMPLE_SNS_TYPE_E enMode, PIC_SIZE_E *penSize)
                HI_S32 SAMPLE_COMM_SYS_GetPicSize(PIC_SIZE_E enPicSize, SIZE_S *pstSize)
                HI_U32 COMMON_GetPicBufferSize()
                    if (0 == u32SupplementConfig)
                    HI_S32 SAMPLE_COMM_SYS_Init(VB_CONFIG_S *pstVbConfig)
                        HI_S32 HI_MPI_SYS_Exit(void)
                        HI_S32 HI_MPI_VB_Exit(void)
                        HI_S32 HI_MPI_VB_SetConfig(const VB_CONFIG_S *pstVbConfig)
                        HI_S32 HI_MPI_VB_Init(void)
                        HI_S32 HI_MPI_SYS_Init(void)
                     else
                     HI_S32 SAMPLE_COMM_SYS_InitWithVbSupplement(VB_CONFIG_S *pstVbConf, HI_U32 u32SupplementConfig)
                        HI_S32 HI_MPI_SYS_Exit(void)
                        HI_S32 HI_MPI_VB_Exit(void)
                        HI_S32 HI_MPI_VB_SetConfig(const VB_CONFIG_S *pstVbConfig)
                        HI_S32 HI_MPI_VB_SetSupplementConfig(const VB_SUPPLEMENT_CONFIG_S *pstSupplementConfig)
                        HI_S32 HI_MPI_VB_Init(void)
                        HI_S32 HI_MPI_SYS_Init(void)
                        
            HI_S32 SAMPLE_COMM_VI_SetParam(SAMPLE_VI_CONFIG_S *pstViConfig)
                HI_S32 HI_MPI_SYS_GetVIVPSSMode(VI_VPSS_MODE_S *pstVIVPSSMode)
                HI_S32 SAMPLE_COMM_VI_UpdateVIVPSSMode(VI_VPSS_MODE_S *pstVIVPSSMode)
                HI_S32 HI_MPI_SYS_SetVIVPSSMode(const VI_VPSS_MODE_S *pstVIVPSSMode)
                
            HI_S32 SAMPLE_COMM_VI_GetFrameRateBySensor(SAMPLE_SNS_TYPE_E enMode, HI_U32 *pu32FrameRate)
            HI_S32 HI_MPI_ISP_GetCtrlParam(VI_PIPE ViPipe, ISP_CTRL_PARAM_S *pstIspCtrlParam)
            HI_S32 HI_MPI_ISP_SetCtrlParam(VI_PIPE ViPipe, const ISP_CTRL_PARAM_S *pstIspCtrlParam)
            
            HI_S32 SAMPLE_COMM_VI_StartVi(SAMPLE_VI_CONFIG_S *pstViConfig)
                 HI_S32 SAMPLE_COMM_VI_StartMIPI(SAMPLE_VI_CONFIG_S *pstViConfig)
                    HI_U32 SAMPLE_COMM_VI_GetMipiLaneDivideMode(SAMPLE_VI_CONFIG_S *pstViConfig)
                        lane_divide_mode_t lane_divide_mode;
                        lane_divide_mode = LANE_DIVIDE_MODE_1;
                        
                    HI_S32 SAMPLE_COMM_VI_SetMipiHsMode(lane_divide_mode_t enHsMode)
                    HI_S32 SAMPLE_COMM_VI_EnableMipiClock(SAMPLE_VI_CONFIG_S *pstViConfig)
                    HI_S32 SAMPLE_COMM_VI_ResetMipi(SAMPLE_VI_CONFIG_S *pstViConfig)
                    HI_S32 SAMPLE_COMM_VI_EnableSensorClock(SAMPLE_VI_CONFIG_S *pstViConfig)
                    HI_S32 SAMPLE_COMM_VI_ResetSensor(SAMPLE_VI_CONFIG_S *pstViConfig)
                    HI_S32 SAMPLE_COMM_VI_SetMipiAttr(SAMPLE_VI_CONFIG_S *pstViConfig)
                    HI_S32 SAMPLE_COMM_VI_UnresetMipi(SAMPLE_VI_CONFIG_S *pstViConfig)
                    HI_S32 SAMPLE_COMM_VI_UnresetSensor(SAMPLE_VI_CONFIG_S *pstViConfig)
                    
                HI_S32 SAMPLE_COMM_VI_SetParam(SAMPLE_VI_CONFIG_S *pstViConfig)
                    HI_S32 HI_MPI_SYS_GetVIVPSSMode(VI_VPSS_MODE_S *pstVIVPSSMode)
                    HI_S32 HI_MPI_SYS_SetVIVPSSMode(const VI_VPSS_MODE_S *pstVIVPSSMode)
                    
                HI_S32 SAMPLE_COMM_VI_CreateVi(SAMPLE_VI_CONFIG_S *pstViConfig)
                    HI_S32 SAMPLE_COMM_VI_CreateSingleVi(SAMPLE_VI_INFO_S *pstViInfo)
                        HI_S32 SAMPLE_COMM_VI_StartDev(SAMPLE_VI_INFO_S *pstViInfo)
                            HI_S32 SAMPLE_COMM_VI_GetDevAttrBySns(SAMPLE_SNS_TYPE_E enSnsType, VI_DEV_ATTR_S *pstViDevAttr)		// case SONY_IMX385_MIPI_2M_30FPS_12BIT
                            HI_S32 HI_MPI_VI_SetDevAttr(VI_DEV ViDev, const VI_DEV_ATTR_S *pstDevAttr)
                            HI_S32 HI_MPI_VI_EnableDev(VI_DEV ViDev)
                            
                        HI_S32 SAMPLE_COMM_VI_BindPipeDev(SAMPLE_VI_INFO_S *pstViInfo)
                            HI_S32 HI_MPI_VI_SetDevBindPipe(VI_DEV ViDev, const VI_DEV_BIND_PIPE_S *pstDevBindPipe)
                            
                        HI_S32 SAMPLE_COMM_VI_StartViPipe(SAMPLE_VI_INFO_S *pstViInfo)
                            HI_S32 SAMPLE_COMM_VI_GetPipeAttrBySns(SAMPLE_SNS_TYPE_E enSnsType, VI_PIPE_ATTR_S *pstPipeAttr) 	// case SONY_IMX385_MIPI_2M_30FPS_12BIT
                            HI_S32 HI_MPI_VI_CreatePipe(VI_PIPE ViPipe, const VI_PIPE_ATTR_S *pstPipeAttr)
                            
                        HI_S32 SAMPLE_COMM_VI_StartViChn(SAMPLE_VI_INFO_S *pstViInfo)
                            HI_S32 HI_MPI_VI_SetChnAttr(VI_PIPE ViPipe, VI_CHN ViChn, const VI_CHN_ATTR_S *pstChnAttr)
                            HI_S32 HI_MPI_VI_EnableChn(VI_PIPE ViPipe, VI_CHN ViChn)
                            
                HI_S32 SAMPLE_COMM_VI_CreateIsp(SAMPLE_VI_CONFIG_S *pstViConfig)
                    HI_S32 SAMPLE_COMM_VI_StartIsp(SAMPLE_VI_INFO_S *pstViInfo)
                        HI_S32 SAMPLE_COMM_VI_GetPipeAttrBySns(SAMPLE_SNS_TYPE_E enSnsType, VI_PIPE_ATTR_S *pstPipeAttr) 		// case SONY_IMX385_MIPI_2M_30FPS_12BIT:
                        
                        HI_S32 SAMPLE_COMM_ISP_GetIspAttrBySns(SAMPLE_SNS_TYPE_E enSnsType, ISP_PUB_ATTR_S *pstPubAttr)			// case SONY_IMX385_MIPI_2M_30FPS_12BIT:
                        
                        HI_S32 SAMPLE_COMM_ISP_Sensor_Regiter_callback(ISP_DEV IspDev, HI_U32 u32SnsId)
                            ISP_SNS_OBJ_S *SAMPLE_COMM_ISP_GetSnsObj(HI_U32 u32SnsId)											// case SONY_IMX385_MIPI_2M_30FPS_12BIT:   return &stSnsImx385Obj;
                            
                        HI_S32 SAMPLE_COMM_ISP_BindSns(ISP_DEV IspDev, HI_U32 u32SnsId, SAMPLE_SNS_TYPE_E enSnsType, HI_S8 s8SnsDev)
                            ISP_SNS_OBJ_S *SAMPLE_COMM_ISP_GetSnsObj(HI_U32 u32SnsId)											// case SONY_IMX385_MIPI_2M_30FPS_12BIT:   return &stSnsImx385Obj;
                            ISP_SNS_TYPE_E SAMPLE_COMM_GetSnsBusType(SAMPLE_SNS_TYPE_E enSnsType)								// enBusType = ISP_SNS_I2C_TYPE;
                            
                        HI_S32 SAMPLE_COMM_ISP_Aelib_Callback(ISP_DEV IspDev)
                        {
                            ALG_LIB_S stAeLib;

                            stAeLib.s32Id = IspDev;
                            strncpy(stAeLib.acLibName, HI_AE_LIB_NAME, sizeof(HI_AE_LIB_NAME));
                            CHECK_RET(HI_MPI_AE_Register(IspDev, &stAeLib), "aelib register call back");
                            return HI_SUCCESS;
                        }
                        
                        HI_S32 SAMPLE_COMM_ISP_Awblib_Callback(ISP_DEV IspDev)
                        {
                            ALG_LIB_S stAeLib;

                            stAeLib.s32Id = IspDev;
                            strncpy(stAeLib.acLibName, HI_AE_LIB_NAME, sizeof(HI_AE_LIB_NAME));
                            CHECK_RET(HI_MPI_AE_UnRegister(IspDev, &stAeLib), "aelib unregister call back");
                            return HI_SUCCESS;
                        }
                        
                        HI_S32 HI_MPI_ISP_MemInit(VI_PIPE ViPipe)
                        
                        HI_S32 HI_MPI_ISP_SetPubAttr(VI_PIPE ViPipe, const ISP_PUB_ATTR_S *pstPubAttr)
                        
                        HI_S32 HI_MPI_ISP_Init(VI_PIPE ViPipe)
                        
                        HI_S32 SAMPLE_COMM_ISP_Run(ISP_DEV IspDev)
                            static void *SAMPLE_COMM_ISP_Thread(void *param)
                                HI_S32 HI_MPI_ISP_Run(VI_PIPE ViPipe)
                                
        void *LOTO_VENC_CLASSIC(void *p)
            HI_S32 LOTO_VENC_VPSS_Init(VPSS_GRP VpssGrp, HI_BOOL *pabChnEnable, DYNAMIC_RANGE_E enDynamicRange, PIXEL_FORMAT_E enPixelFormat, SIZE_S *stSize, SAMPLE_SNS_TYPE_E enSnsType)
                HI_S32 SAMPLE_COMM_VI_GetSizeBySensor(SAMPLE_SNS_TYPE_E enMode, PIC_SIZE_E *penSize)
                HI_S32 SAMPLE_COMM_SYS_GetPicSize(PIC_SIZE_E enPicSize, SIZE_S *pstSize)
                HI_S32 SAMPLE_COMM_VPSS_Start(VPSS_GRP VpssGrp, HI_BOOL *pabChnEnable, VPSS_GRP_ATTR_S *pstVpssGrpAttr, VPSS_CHN_ATTR_S *pastVpssChnAttr)
                    HI_S32 HI_MPI_VPSS_CreateGrp(VPSS_GRP VpssGrp, const VPSS_GRP_ATTR_S *pstGrpAttr)
                    HI_S32 HI_MPI_VPSS_SetChnAttr(VPSS_GRP VpssGrp, VPSS_CHN VpssChn, const VPSS_CHN_ATTR_S *pstChnAttr)
                    HI_S32 HI_MPI_VPSS_EnableChn(VPSS_GRP VpssGrp, VPSS_CHN VpssChn)
                    HI_S32 HI_MPI_VPSS_StartGrp(VPSS_GRP VpssGrp)
                
            HI_S32 SAMPLE_COMM_VI_Bind_VPSS(VI_PIPE ViPipe, VI_CHN ViChn, VPSS_GRP VpssGrp)
                HI_S32 HI_MPI_SYS_Bind(const MPP_CHN_S *pstSrcChn, const MPP_CHN_S *pstDestChn)
                
            HI_S32 SAMPLE_COMM_VENC_GetGopAttr(VENC_GOP_MODE_E enGopMode, VENC_GOP_ATTR_S *pstGopAttr)				// 获取Gop属性
                
            HI_S32 SAMPLE_COMM_VENC_Start(VENC_CHN VencChn, PAYLOAD_TYPE_E enType, PIC_SIZE_E enSize, SAMPLE_RC_E enRcMode, HI_U32 u32Profile, HI_BOOL bRcnRefShareBuf, VENC_GOP_ATTR_S *pstGopAttr)
                HI_S32 SAMPLE_COMM_VENC_Creat(VENC_CHN VencChn, PAYLOAD_TYPE_E enType, PIC_SIZE_E enSize, SAMPLE_RC_E enRcMode, HI_U32 u32Profile, HI_BOOL bRcnRefShareBuf, VENC_GOP_ATTR_S *pstGopAttr)
                    HI_S32 SAMPLE_COMM_SYS_GetPicSize(PIC_SIZE_E enPicSize, SIZE_S *pstSize)
                    void SAMPLE_COMM_VI_GetSensorInfo(SAMPLE_VI_CONFIG_S *pstViConfig)
                    HI_S32 SAMPLE_COMM_VI_GetFrameRateBySensor(SAMPLE_SNS_TYPE_E enMode, HI_U32 *pu32FrameRate)
                    HI_S32 HI_MPI_VENC_CreateChn(VENC_CHN VeChn, const VENC_CHN_ATTR_S *pstAttr)					// 根据通道信息创建编码通道
                    HI_S32 SAMPLE_COMM_VENC_CloseReEncode(VENC_CHN VencChn)
                        HI_S32 HI_MPI_VENC_GetChnAttr(VENC_CHN VeChn, VENC_CHN_ATTR_S *pstChnAttr)
                        HI_S32 HI_MPI_VENC_GetRcParam(VENC_CHN VeChn, VENC_RC_PARAM_S *pstRcParam)
                        HI_S32 HI_MPI_VENC_SetRcParam(VENC_CHN VeChn, const VENC_RC_PARAM_S *pstRcParam)
                HI_S32 HI_MPI_VENC_StartRecvFrame(VENC_CHN VeChn, const VENC_RECV_PIC_PARAM_S *pstRecvParam)
                
            HI_S32 SAMPLE_COMM_VPSS_Bind_VENC(VPSS_GRP VpssGrp, VPSS_CHN VpssChn, VENC_CHN VencChn)
                HI_S32 HI_MPI_SYS_Bind(const MPP_CHN_S *pstSrcChn, const MPP_CHN_S *pstDestChn)
                
            HI_S32 SAMPLE_COMM_VENC_StartGetStream(pthread_t *vencPid, VENC_CHN *VeChn, HI_S32 s32Cnt)
                void *SAMPLE_COMM_VENC_GetVencStreamProc(void *p)
                    HI_S32 HI_MPI_VENC_GetChnAttr(VENC_CHN VeChn, VENC_CHN_ATTR_S *pstChnAttr)
                    HI_S32 SAMPLE_COMM_VENC_GetFilePostfix(PAYLOAD_TYPE_E enPayload, char *szFilePostfix)
                    HI_S32 HI_MPI_VENC_GetStreamBufInfo(VENC_CHN VeChn, VENC_STREAM_BUF_INFO_S *pstStreamBufInfo)
                    
                    FD_ZERO(&read_fds);																				// get stream from each channels and save them
                    s32Ret = select(maxfd + 1, &read_fds, NULL, NULL, &TimeoutVal);
                    HI_S32 HI_MPI_VENC_QueryStatus(VENC_CHN VeChn, VENC_CHN_STATUS_S *pstStatus)
                    HI_S32 HI_MPI_VENC_GetStream(VENC_CHN VeChn, VENC_STREAM_S *pstStream, HI_S32 s32MilliSec)
                    HI_S32 HI_MPI_VENC_ReleaseStream(VENC_CHN VeChn, VENC_STREAM_S *pstStream)
            
        void *LOTO_AENC_AAC_CLASSIC(void *p)
            HI_MPI_AENC_AacInit();      // 注册 AAC 编码器
                static HI_S32 InitAacAencLib(void)
                HI_S32 HI_MPI_AENC_RegisterEncoder(HI_S32 *ps32Handle, const AENC_ENCODER_S *pstEncoder)
                
            LOTO_AUDIO_AiAenc();        // AI --> AENC --> Buffer
                /* Step 1: Start AI */
                HI_S32 SAMPLE_COMM_AUDIO_StartAi(AUDIO_DEV AiDevId, HI_S32 s32AiChnCnt,
                                    AIO_ATTR_S* pstAioAttr, AUDIO_SAMPLE_RATE_E enOutSampleRate, HI_BOOL bResampleEn, HI_VOID* pstAiVqeAttr, HI_U32 u32AiVqeType)
                    HI_S32 HI_MPI_AI_SetPubAttr(AUDIO_DEV AiDevId, const AIO_ATTR_S *pstAttr)
                    HI_S32 HI_MPI_AI_Enable(AUDIO_DEV AiDevId)
                    HI_S32 HI_MPI_AI_EnableChn(AUDIO_DEV AiDevId, AI_CHN AiChn)
                    HI_S32 HI_MPI_AI_EnableReSmp(AUDIO_DEV AiDevId, AI_CHN AiChn, AUDIO_SAMPLE_RATE_E enOutSampleRate)
                    HI_S32 HI_MPI_AI_SetRecordVqeAttr(AUDIO_DEV AiDevId, AI_CHN AiChn, const AI_RECORDVQE_CONFIG_S *pstVqeConfig)
                    HI_S32 HI_MPI_AI_EnableVqe(AUDIO_DEV AiDevId, AI_CHN AiChn)
                
                /* Step 2: Config audio codec */
                HI_S32 SAMPLE_COMM_AUDIO_CfgAcodec(AIO_ATTR_S *pstAioAttr)
                    HI_S32 SAMPLE_INNER_CODEC_CfgAudio(AUDIO_SAMPLE_RATE_E enSample)
                    
                /* Step 3: Start aenc */
                HI_S32 SAMPLE_COMM_AUDIO_StartAenc(HI_S32 s32AencChnCnt, AIO_ATTR_S *pstAioAttr, PAYLOAD_TYPE_E enType)
                    HI_S32 HI_MPI_AENC_CreateChn(AENC_CHN AeChn, const AENC_CHN_ATTR_S *pstAttr)
                
                /* Step 4: Aenc bind Ai Chn */
                HI_S32 SAMPLE_COMM_AUDIO_AencBindAi(AUDIO_DEV AiDev, AI_CHN AiChn, AENC_CHN AeChn)
                    HI_S32 HI_MPI_SYS_Bind(const MPP_CHN_S *pstSrcChn, const MPP_CHN_S *pstDestChn)
                
                /* Step 5: Start Adec & Ao. ( if you want ) */
                HI_S32 LOTO_AUDIO_CreatTrdAenc(pthread_t *aencPid, AENC_CHN AeChn)
                    void* LOTO_COMM_AUDIO_AencProc(void* parg)
                        HI_S32 HI_MPI_AENC_GetFd(AENC_CHN AeChn)
                        HI_S32 HI_MPI_AENC_GetStream(AENC_CHN AeChn, AUDIO_STREAM_S *pstStream, HI_S32 s32MilliSec)
                        HI_S32 HisiPutAACDataToBuffer(AUDIO_STREAM_S *aacStream) // get stream from Aenc, send it to ringfifo
                        HI_S32 HI_MPI_AENC_ReleaseStream(AENC_CHN AeChn, const AUDIO_STREAM_S *pstStream)
                
                /* Step 6: Exit process */
                HI_S32 LOTO_AUDIO_DestoryTrdAenc(AENC_CHN AeChn)
                
                
            HI_MPI_AENC_AacDeInit();    // 注销 AAC 编码器
            SAMPLE_COMM_SYS_Exit();     // Exit system
                HI_MPI_SYS_Exit();
                HI_MPI_VB_ExitModCommPool(VB_UID_VDEC);
                HI_MPI_VB_Exit();

    
    void *LOTO_VIDEO_AUDIO_RTMP(void *p)
        int rtmp_sender_write_audio_frame(void *handle, uint8_t *data, int size, uint64_t dts_us, uint32_t start_time)
        int rtmp_sender_write_video_frame(void *handle, uint8_t *data, int size, uint64_t dts_us, int key, uint32_t start_time)
            
        
        
        
        
```

