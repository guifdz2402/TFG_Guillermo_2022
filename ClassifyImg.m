function NewClassified = ClassifyImg(net,im,linea,ClassifiedData)

    % Recibe la red neuronal y la imagen para classificarla. Se guardará el
    % dato en la variable Classified siguiendo el patrón: 
    % 1 - pinza cerrada
    % 2 - pinza abierta
    % 3 - pinza indeterminada
 
    inputSize = net.Layers(1).InputSize;

    imaug = augmentedImageDatastore(inputSize,im,...
                   'ColorPreprocessing','gray2rgb');

    texto = string(classify(net,imaug));

    if (strcmp(texto,"Cerrada")==1)
        ClassifiedData(linea,1) = 1;
        NewClassified = ClassifiedData;
    end

    if (strcmp(texto,"Abierta")==1)
        ClassifiedData(linea,1) = 2;
        NewClassified = ClassifiedData;
    end

    if (strcmp(texto,"Indeterminada")==1)
        ClassifiedData(linea,1) = 3;
        NewClassified = ClassifiedData;
    end    

    % Igualamos el dato obtenido al valor de la linea anterior

    if linea ~= 1
        NewClassified(linea-1,1)=NewClassified(linea,1);
    end

end