%% Muestra conjunto de imágenes del DataSet


% 1) Carga conjunto de imagenes
imds = imageDatastore('.\Muestras', ...
    'IncludeSubfolders',true,'LabelSource','foldernames');
    % Muestra 20 imágenes de la muestra tomadas al azar
        figure('Name','MUESTREO')
        perm = randperm(numel(imds.Files),20); % 20 números aleatorios
        for k = 1:20
            subplot(4,5,k);
            im = readimage(imds,perm(k));
            % lee una imagen dando su número en la base de datos
            imshow(im);
        end

 %% Entrenamiento de la red neuronal convolucional

% 2) División del dataset en datos de entrenamiento, validación y test
%    (10% test, 80% train, 10% validation )
[test_data,trainval_data] = splitEachLabel(imds,0.1,'randomize');
[train_data,val_data] = splitEachLabel(trainval_data,0.9,'randomize');

% 3) Definición modelo de entrenamiento - Carga modelo ya entrenado
net= resnet18;
inputSize = net.Layers(1).InputSize;

if isa(net,'SeriesNetwork')
    lgraph = layerGraph(net.Layers);
else
    lgraph = layerGraph(net);
end

% Detección de las capas a sustituir
[learnableLayer,classLayer] = findLayersToReplace(lgraph);

% Adecuación de la última capa al número de clases de nuestro caso concreto
numClasses = numel(categories(train_data.Labels));

if isa(learnableLayer,'nnet.cnn.layer.FullyConnectedLayer')
    newLearnableLayer = fullyConnectedLayer(numClasses, ...
        'Name','new_fc', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
    
elseif isa(learnableLayer,'nnet.cnn.layer.Convolution2DLayer')
    newLearnableLayer = convolution2dLayer(1,numClasses, ...
        'Name','new_conv', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
end

lgraph = replaceLayer(lgraph,learnableLayer.Name,newLearnableLayer);

% Modificación capa de clasf. para introducir las etiquetas del caso estudiado
newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,classLayer.Name,newClassLayer);
    
% 4) Entrenamiento del modelo
miniBatchSize=10;
% - Redimensionar imagenes entrada para la red utilizada
augmenter=imageDataAugmenter(... % Añadimos a la BBDD imagenes rotadas y espejadas
    'RandRotation',[-20,20], ...
    'RandXReflection',true, ...
    'RandYReflection',true);
resizedTrainingSet=augmentedImageDatastore(inputSize,train_data, ...
    'DataAugmentation',augmenter, ...
    'ColorPreprocessing','gray2rgb');
resizedTrainingSet.MiniBatchSize = miniBatchSize;

resizedValSet=augmentedImageDatastore(inputSize,val_data,...
    'ColorPreprocessing','gray2rgb');
resizedValSet.MiniBatchSize = miniBatchSize;

% - Definición parámetros entrenamiento
options = trainingOptions('sgdm', ...
    'LearnRateSchedule','piecewise',...
    'InitialLearnRate',0.001, ...
    'LearnRateDropPeriod',5,...
    'LearnRateDropFactor',0.2,...
    'MaxEpochs',10, ...
    'Shuffle','every-epoch', ...
    'ValidationData',resizedValSet, ...
    'ValidationFrequency',20, ...
    'MiniBatchSize',miniBatchSize, ...
    'Verbose',false, ...
    'Plots','training-progress');

% - Entrenamiento del modelo con imagenes redimensionadas
trainedNet = trainNetwork(resizedTrainingSet,lgraph,options);

%% Evaluación de resultados

% 5) Evaluación resultados obtenidos
% -  Obtención predicciones para conjunto de datos de test
inputSize = trainedNet.Layers(1).InputSize;
resizedTestSet=augmentedImageDatastore(inputSize,test_data,...
                   'ColorPreprocessing','gray2rgb');

pred = classify(trainedNet,resizedTestSet);
true_labels = test_data.Labels;

% -  Cálculo del índice de aciertos en el batch de validación
accuracy = sum(pred == true_labels)/numel(true_labels)

%% Predicciones en el batch de validación

    figure('Name','PREDICCIONES')
    perm = randperm(numel(trainval_data.Files),9); % 20 números aleatorios
    for k = 1:9
        subplot(3,3,k);
        im = readimage(trainval_data,perm(k)); % lee una imagen dando su número en la base de datos
        imshow(im);
        augIm = augmentedImageDatastore(inputSize,im,...
               'ColorPreprocessing','gray2rgb');
        [YPred,probs] = classify(trainedNet,augIm);
        label = YPred;
        title(string(label) + ", " + num2str(100*max(probs(1,:)),3) + "%");
    end

 %% Predicciones para video Pea on a Peg

     imds_PeaOnAPeg = imageDatastore('.\Muestras_PeaOnAPeg', ...
        'IncludeSubfolders',true,'LabelSource','foldernames');

     % -  Obtención predicciones 
    inputSize = trainedNet.Layers(1).InputSize;
    resizedPeaOnAPeg=augmentedImageDatastore(inputSize,imds_PeaOnAPeg,...
                       'ColorPreprocessing','gray2rgb');
    
    pred_PeaOnAPeg = classify(trainedNet,resizedPeaOnAPeg);
    true_labels_PeaOnAPeg = imds_PeaOnAPeg.Labels;
    
    % -  Cálculo del índice de aciertos
    accuracy_PeaOnAPeg = sum(pred_PeaOnAPeg == true_labels_PeaOnAPeg)/numel(true_labels_PeaOnAPeg)

    % -  Verificación gráfica de predicciones

    figure('Name','PREDICCIONES PEA ON A PEG')
    perm = randperm(numel(imds_PeaOnAPeg.Files),9); % 20 números aleatorios
    for k = 1:9
        subplot(3,3,k);
        im = readimage(imds_PeaOnAPeg,perm(k)); % lee una imagen dando su número en la base de datos
        imshow(im);
        augIm = augmentedImageDatastore(inputSize,im,...
               'ColorPreprocessing','gray2rgb');
        [YPred,probs] = classify(trainedNet,augIm);
        label = YPred;
        title(string(label) + ", " + num2str(100*max(probs(1,:)),3) + "%");
    end

 
%% Predicciones para video Post and Sleeve

     imds_PostAndSleeve = imageDatastore('.\Muestras_PostAndSleeve', ...
        'IncludeSubfolders',true,'LabelSource','foldernames');

     % -  Obtención predicciones 
    inputSize = trainedNet.Layers(1).InputSize;
    resizedPostAndSleeve=augmentedImageDatastore(inputSize,imds_PostAndSleeve,...
                       'ColorPreprocessing','gray2rgb');
    
    pred_PostAndSleeve = classify(trainedNet,resizedPostAndSleeve);
    true_labels_PostAndSleeve = imds_PostAndSleeve.Labels;
    
    % -  Cálculo del índice de aciertos
    accuracy_PostAndSleeve = sum(pred_PostAndSleeve == true_labels_PostAndSleeve)/numel(true_labels_PostAndSleeve)

    % -  Verificación gráfica de predicciones

    figure('Name','PREDICCIONES POST AND SLEEVE')
    perm = randperm(numel(imds_PostAndSleeve.Files),9); % 20 números aleatorios
    for k = 1:9
        subplot(3,3,k);
        im = readimage(imds_PostAndSleeve,perm(k)); % lee una imagen dando su número en la base de datos
        imshow(im);
        augIm = augmentedImageDatastore(inputSize,im,...
               'ColorPreprocessing','gray2rgb');
        [YPred,probs] = classify(trainedNet,augIm);
        label = YPred;
        title(string(label) + ", " + num2str(100*max(probs(1,:)),3) + "%");
    end

  %% Predicciones para video Wire Chaser

     imds_WireChaser = imageDatastore('.\Muestras_WireChaser', ...
        'IncludeSubfolders',true,'LabelSource','foldernames');

     % -  Obtención predicciones 
    inputSize = trainedNet.Layers(1).InputSize;
    resizedWireChaser=augmentedImageDatastore(inputSize,imds_WireChaser,...
                       'ColorPreprocessing','gray2rgb');
    
    pred_WireChaser = classify(trainedNet,resizedWireChaser);
    true_labels_WireChaser = imds_WireChaser.Labels;
    
    % -  Cálculo del índice de aciertos
    accuracy_WireChaser = sum(pred_WireChaser == true_labels_WireChaser)/numel(true_labels_WireChaser)

    % -  Verificación gráfica de predicciones

    figure('Name','PREDICCIONES WIRE CHASER')
    perm = randperm(numel(imds_WireChaser.Files),9); % 20 números aleatorios
    for k = 1:9
        subplot(3,3,k);
        im = readimage(imds_WireChaser,perm(k)); % lee una imagen dando su número en la base de datos
        imshow(im);
        augIm = augmentedImageDatastore(inputSize,im,...
               'ColorPreprocessing','gray2rgb');
        [YPred,probs] = classify(trainedNet,augIm);
        label = YPred;
        title(string(label) + ", " + num2str(100*max(probs(1,:)),3) + "%");
    end