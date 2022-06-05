function neWData = AddRowsToData(ExistingData,PSM1_tool,PSM2_tool)

    % Añade las columnas al conjunto de datos ExistingData (FZ y GA)
    

%     PSM1_tool = table(PSM1_tool);
%     PSM2_tool = table(PSM2_tool);

    if height(PSM1_tool)<height(ExistingData)
        for i=(height(PSM1_tool)+1):1:height(ExistingData)
            PSM1_tool(i,1)=0;
            PSM2_tool(i,1)=0;
        end
    end

    PSM1_tool = table(PSM1_tool);
    PSM2_tool = table(PSM2_tool);

    neWData = [ExistingData,PSM1_tool,PSM2_tool];

end 