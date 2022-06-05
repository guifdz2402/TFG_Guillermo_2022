function tiempo = TextToTime(x,tabla)

    % Recibe la linea del archivo de la que se quiere obtener el tiempo de
    % video y devuelve la salida en formato datetime de ese tiempo
 
    %global TableCell;
    aux=tabla(x,1); %seleccionamos la celda que contiene el tiempo inicial
    text=cell2mat(aux); %pasamos al formato de texto

    %en los datos, los milissegundos que valen menos que 100 están con mal
    %formato. Arreglamos basándonos en el tamaño del vector:

    [~,tam] = size(text);
    if tam==21
        text = strcat(text(1:20),'00',text(21));
    end

    if tam==22
        text = strcat(text(1:20),'0',text(21));
    end

    tiempo=datetime(text,'InputFormat','yyyy-MM-dd.HH:mm:ss.SSS'); %convertimos la variable a tipo tiempo para poder operar con ella

    

end