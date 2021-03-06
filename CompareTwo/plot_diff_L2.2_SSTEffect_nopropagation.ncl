load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "contrib_JJB.ncl"

begin
	print("=============== in plot_diff_L2.2_SSTEffect_nopropagation.ncl =================")
	
	progGen		= ".make_L2.2_regression_nopropagation."

	;------------- set dynamic variable names
	CTRLNAME	= getenv("CTRLCASE")
	CTRLDIR		= getenv("CTRLDIR")
	EXPNAME		= getenv("EXPCASE")
	diri		= CTRLDIR + "proc/" + CTRLNAME + "_minus_" + EXPNAME + "/" 
	print("diri = " + diri)
	dirp		=  CTRLDIR + "plots/"
	print("dirp = " + dirp)
	
	;------------- define season names
	seasonName 	= (/ "Nov-Apr", "May-Oct" /)

	;----------- note:  input variables and metadata for plotting
	;					routines use standard naming conventions
	varName		= (/ "LHFLX",	"comptotLH", 			"wdLH", 			"tdLH",				"ecLH" /)
	varID		= (/ "LHFLX",	"component total LH",	"wind-driven LH",	"thermodynamic LH",	"eddy covariance LH"/)

	;------------- plot resources for shaded base plot
	res 						= True
	res@vpWidthF				= 0.8
	res@vpHeightF				= 0.4
	res@gsnDraw             	= False			; don't draw
	res@gsnFrame            	= False			; don't advance frame
	res@cnInfoLabelOn       	= False 		; turn off cn info label
	res@cnFillOn            	= True			; turn on color
	res@cnLinesOn				= False			; turn off contour lines
	res@tmXBLabelsOn			= False
	res@gsnSpreadColors     	= True			; spread out color table
	res@gsnSpreadColorStart 	= 2 
	res@gsnSpreadColorEnd   	= -3 
	res@lbOrientation        	= "Vertical"	; vertical label bar
	res@cnLevelSelectionMode 	= "ExplicitLevels"   
	res@cnLevels 				= fspan(-2.5,2.5,11)
	res@tmXBLabelFontHeightF 	= 0.025		
	res@tmYLLabelFontHeightF 	= 0.025		
	res@tmEqualizeXYSizes		= True
	res@txFontHeightF			= 0.03
	res@tiYAxisString			= "lag (day)"

	;------------- plot resources for overlaid MSE
	resM								= True		; Precipitation resources
	resM@vpWidthF						= 0.8
	resM@vpHeightF						= 0.4
	resM@gsnDraw						= False		; don't draw
	resM@gsnFrame						= False		; don't advance frame
	resM@cnInfoLabelOn					= False		; turn off cn info label
	resM@gsnLeftString					= ""		; no titles
	resM@gsnRightString					= ""
	resM@tiXAxisString					= ""
	resM@cnLineThicknessF				= 1.5		; thicker contours
	resM@cnLineLabelsOn					= False		; no line labels
	resM@gsnContourZeroLineThicknessF	= 0.		; doubles thickness of zero contour
	resM@gsnContourNegLineDashPattern	= 1 		; sets negative contours to dash pattern 1
	resM@cnLevelSelectionMode 			= "ExplicitLevels"   
	resM@tmXBLabelFontHeightF 			= 0.025		
	resM@tmYLLabelFontHeightF 			= 0.025		
	resM@tmEqualizeXYSizes				= True
	resM@cnLevels						= fspan(-1,1,11)

	resR						= True 					; plot mods desired
	resR@gsnDraw				= False					; don't draw
	resR@gsnFrame				= False					; don't advance frame
	resR@xyLineColors     		= "black"				; line colors
	resR@xyLineThicknessF		= 2.
	resR@tmXBLabelFontHeightF 	= 0.025		
	resR@tmYLLabelFontHeightF 	= 0.025			
	
	resL						= True
	resL@gsLineThicknessF		= 1.0
	resL@gsLineColor			= "black"

	do s = 0,1 						; do for each season
	
	;------------set up the plot
		wksType = "pdf"
		wksName= dirp + CTRLNAME + "_minus_"+ EXPNAME + ".plot_diff_L2.2_SSTEffect_nopropogation." + seasonName(s)
		wks = gsn_open_wks(wksType,wksName)		; open a ps file
		gsn_define_colormap(wks,"cmp_b2r")
		plot = new(10,graphic)                 	; create a plot array
		
			;------------ read in the MSE data
			tName			= "Vmse"
			fili			= diri +  CTRLNAME + "_minus_"+ EXPNAME + progGen +"PRECT." + tName + "." +  seasonName(s) + ".nc"
			f				= addfile(fili,"r")
			lag				= f->lag
			lon				= f->lon
			mse				= f->$tName$
			mse				= 1E-06 * mse
			mse@units		= "[10~S~6 [J/m**2]/[mm/day]"
			rainsd			= f->gridp_stdev({30:240})
			lonind			= ind(lon.ge.30.and.lon.le.240)
			;printVarSummary(rainsd)
			resR@tiYAxisString		= rainsd@units			; y axis title
			resR@tiXAxisString		= rainsd&lon@units

			;------------ wind-driven LHFLX+SHFLX (full SST)
			tName			= "LHFLX"
			fili			= diri +  CTRLNAME + "_minus_"+ EXPNAME + progGen + "PRECT." + tName + "." + seasonName(s) + ".nc"
			f				= addfile(fili,"r")
			lh_full			= f->$tName$
			tName			= "SHFLX"
			fili			= diri +  CTRLNAME + "_minus_"+ EXPNAME + progGen + "PRECT." + tName + "." + seasonName(s) + ".nc"
			f				= addfile(fili,"r")
			sh_full			= f->$tName$
						
			wd_full			= lh_full + sh_full
			copy_VarMeta(lh_full,wd_full)
			wd_full@long_name	= "wind-driven LH+SH, full SST"
			wd_full@units	= "W m~S2~-2"

			;------------ thermodynamic LHFLX+SHFLX (full SST)
			tName			= "tdLH"
			fili			= diri +  CTRLNAME + "_minus_"+ EXPNAME + progGen + "PRECT." + tName + "." + seasonName(s) + ".nc"
			f				= addfile(fili,"r")
			lh_full			= f->$tName$
			tName			= "tdSH"
			fili			= diri +  CTRLNAME + "_minus_"+ EXPNAME + progGen + "PRECT." + tName + "." + seasonName(s) + ".nc"
			f				= addfile(fili,"r")
			sh_full			= f->$tName$
						
			td_full			= lh_full + sh_full
			copy_VarMeta(lh_full,td_full)
			td_full@long_name	= "thermodynamic LH+SH, full SST"
			td_full@units	= "W m~S2~-2"
			
			;------------ second order LHFLX+SHFLX (full SST)
			tName			= "ecLH"
			fili			= diri +  CTRLNAME + "_minus_"+ EXPNAME + progGen + "PRECT." + tName + "." + seasonName(s) + ".nc"
			f				= addfile(fili,"r")
			lh_full			= f->$tName$
			tName			= "ecSH"
			fili			= diri +  CTRLNAME + "_minus_"+ EXPNAME + progGen + "PRECT." + tName + "." + seasonName(s) + ".nc"
			f				= addfile(fili,"r")
			sh_full			= f->$tName$
						
			ec_full			= lh_full + sh_full
			copy_VarMeta(lh_full,ec_full)
			ec_full@long_name	= "second order LH+SH, full SST"
			ec_full@units	= "W m~S2~-2"

			;------------ component total LHFLX+SHFLX (full SST)
			tName			= "comptotLH"
			fili			= diri +  CTRLNAME + "_minus_"+ EXPNAME + progGen + "PRECT." + tName + "." + seasonName(s) + ".nc"
			f				= addfile(fili,"r")
			lh_full			= f->$tName$
			tName			= "comptotSH"
			fili			= diri +  CTRLNAME + "_minus_"+ EXPNAME + progGen + "PRECT." + tName + "." + seasonName(s) + ".nc"
			f				= addfile(fili,"r")
			sh_full			= f->$tName$
						
			ct_full			= lh_full + sh_full
			copy_VarMeta(lh_full,ct_full)
			ct_full@long_name	= "component total LH+SH, full SST"
			ct_full@units	= "W m~S2~-2"

			;------------ component total LHFLX+SHFLX (smoothed SST)
			tName			= "comptotLH_smSST"
			fili			= diri +  CTRLNAME + "_minus_"+ EXPNAME + progGen + "PRECT." + tName + "." + seasonName(s) + ".nc"
			f				= addfile(fili,"r")
			lh_full			= f->$tName$
			tName			= "comptotSH_smSST"
			fili			= diri +  CTRLNAME + "_minus_"+ EXPNAME + progGen + "PRECT." + tName + "." + seasonName(s) + ".nc"
			f				= addfile(fili,"r")
			sh_full			= f->$tName$
						
			ct_sm			= lh_full + sh_full
			copy_VarMeta(lh_full,ct_sm)
			ct_sm@long_name	= "component total LH+SH, smoothed SST"
			ct_sm@units	= " "

			;------------ difference
			diff			= ct_full - ct_sm
			copy_VarMeta(lh_full,diff)
			diff@long_name	= "difference, full SST - smoothed SST"
			diff@units	= " "

			;------------ make plots
			plotR	= gsn_csm_contour(wks, smth9_Wrap(mse(:,lonind),0.5,0.25,False), resM )
			plota	= gsn_csm_contour(wks, smth9_Wrap(wd_full(:,lonind),0.5,0.25,False), res )
			x		= (/ 40, 210 /)
			y		= (/ 0,0 /)
			printVarSummary(plotR)
			printVarSummary(smth9_Wrap(mse(:,lonind),0.5,0.25,False))
			;gsn_polyline(wks,x,y,plotR,resL)
			overlay(plota,plotR)
			plot(0)	= plota			; wind-driven
			delete(plota)
			delete(plotR)
			
			plotR	= gsn_csm_contour(wks, smth9_Wrap(mse(:,lonind),0.5,0.25,False), resM )
			plota	= gsn_csm_contour(wks, smth9_Wrap(td_full(:,lonind),0.5,0.25,False), res )
			overlay(plota,plotR)
			plot(2)	= plota			; thermodynamic
			delete(plota)
			delete(plotR)

			res@tmXBLabelsOn			= True
			plotR	= gsn_csm_contour(wks, smth9_Wrap(mse(:,lonind),0.5,0.25,False), resM )
			plota	= gsn_csm_contour(wks, smth9_Wrap(ec_full(:,lonind),0.5,0.25,False), res )
			overlay(plota,plotR)
			plot(4)	= plota			; second-order
			delete(plota)
			delete(plotR)
			
			res@tmXBLabelsOn			= False
			plotR	= gsn_csm_contour(wks, smth9_Wrap(mse(:,lonind),0.5,0.25,False), resM )
			plota	= gsn_csm_contour(wks, smth9_Wrap(ct_full(:,lonind),0.5,0.25,False), res )
			overlay(plota,plotR)
			plot(1)	= plota			; componenet total, full SST
			delete(plota)
			delete(plotR)
			
			plotR	= gsn_csm_contour(wks, smth9_Wrap(mse(:,lonind),0.5,0.25,False), resM )
			plota	= gsn_csm_contour(wks, smth9_Wrap(ct_sm(:,lonind),0.5,0.25,False), res )
			overlay(plota,plotR)
			plot(3)	= plota			; componenet total, smoothed SST
			delete(plota)
			delete(plotR)
			
			res@tmXBLabelsOn			= True
			plotR	= gsn_csm_contour(wks, smth9_Wrap(mse(:,lonind),0.5,0.25,False), resM )
			plota	= gsn_csm_contour(wks, smth9_Wrap(diff(:,lonind),0.5,0.25,False), res )
			overlay(plota,plotR)
			plot(5)	= plota			; difference
			delete(plota)
			delete(plotR)
						
			resR@vpKeepAspect		= True
			rainsd@long_name		= " "
			resR@tiXAxisString		= " "
			resR@vpHeightF			= 0.2
			resR@vpWidthF			= 0.8
			plot(7) = gsn_csm_xy(wks,rainsd&lon,rainsd,resR)          ; Draw an XY plot with 1 curve.



		;------------- create page
		pStr		= (/"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z" /)
		nPanels		= 8 ; panel 7 is not plotted
		pID			= new(nPanels,"string")
		print("nPanels = "+nPanels)
		do i=0,nPanels/2-1
			pID(i*2)	= pStr(i)
			pID(i*2+1)	= pStr(i+nPanels/2)
		end do
		pID			= (/"a","d","b","e","c","f","","g"/)
		;pID(7) = "" ; don't draw label for this panel

		print("creating plot page...")
		resP                  = True                   ; modify the panel plot
		resP@gsnFrame         = False                  ; don't advance panel plot
		resP@gsnPanelLabelBar = False                  ; add common colorbar
		resP@txString			= CTRLNAME + " - " + EXPNAME + "," + " "+ seasonName(s)
		resP@gsnPanelBottom   = 0.05                   ; add space at bottom
		resP@gsnPanelYWhiteSpacePercent = 4
		resP@gsnPanelFigureStrings = pID      ; add letter labels to panels (# letters can be > # panels)
		resP@gsnPanelFigureStringsFontHeightF	= 0.012
		resP@gsnPanelFigureStringsPerimOn		= True
		resP@amJust								= "TopLeft"
		gsn_panel(wks,plot,(/5,2/),resP)               ; now draw as one plot

		;------------- print sign convention
		txres               	= True                     	; text mods desired
		txres@txFontHeightF		= 0.013                    	; font smaller. default big
		;gsn_text_ndc(wks,"[positive (negative) anomalies moisten (dry) the atmosphere]",0.1,0.3,txres) 
		;gsn_text_ndc(wks,"40E-180E avg ~F33~s~F21~(rain) = "+sprintf("%5.2f",bpbar)+".  Overlay:  MSE; contour interval = 1x10~S~6~N~ [J/m**2]/[mm/day]",0.5,0.008,txres) 

		res@tmXBLabelsOn	= False 	; turn off longitude labels for next season plots

	end do	; season loop

end
