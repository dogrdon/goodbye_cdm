SET CDM_DIR=%0%
SET CDM_DIR=%CDM_DIR:cdm.bat=%
SET CDM_DIR=%CDM_DIR:"=%
SET SAXON_JAR=%CDM_DIR%saxon9.jar
SET SAXON=java -jar "%SAXON_JAR%"
SET OUTPUT_DIR=%CDM_DIR%output
SET STYLESHEET=%CDM_DIR%cdm.xsl
%SAXON% %1 "%STYLESHEET%" "outputdir=%OUTPUT_DIR%" translate-path=yes
PAUSE
