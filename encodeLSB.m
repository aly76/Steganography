function [nSamples, nBits, isImage, payloadDim, payloadLength, alloc, imgDim] = encodeLSB(cover, payload, nBits, varargin)
    % Encoder for LSB method of steganography
    % Generates the watermarked image in current working directory e.g.'originalImage_640_watermarked.bmp'
    % Alan Ly & Alex Chin, 2018
    % 
    % Inputs
    % cover - Source image used to carry the message e.g. 'originalImage_640.png'
    % payload - Message to be embedded into the original image e.g. 'Text' or 'tinyImage_320.bmp'
    % nBits - No. of bits per sample/pixel allocated to the message
    % 
    % Outputs
    % Provided for convenience... 
    % Used by the decoder to extract message
    % In reality, only the intended receipient of the message would know these
    % nSamples - Number of samples in the image that contain the message
    % nBits - Same as above 
    % isImage - Whether the payload is an image or string 
    % payloadDim - resolution of the payload (if it's an image)
    % payloadLength - no. bits in the payload...used by decoder if nBits is odd
    % alloc - the algorithm used for allocation of payload e.g. pseudo-random
    %% Parse function arguments
    [extension, filename] = regexp(cover, '\.\w*', 'match', 'split', 'ignorecase');
    
    supportedFormats = {'.bmp', '.jpg', '.png'};
    findExt = strfind(supportedFormats, extension); 
    supportFlag = 0;
    % Check if file extension is supported
    for i = 1:length(supportedFormats)
        if (findExt{1,i} == 1)
            supportFlag = 1; 
            break;
        end 
    end 
    assert(supportFlag ~= 0, 'The file extension is not supported') 
    
    % Determine whether the payload is a string or image
    [payloadExtension, payloadFilename] = regexp(payload, '\.\w*', 'match', 'split', 'ignorecase'); 
    if (~isempty(payloadExtension))
        payload = imread(payloadFilename{1}, payloadExtension{1}(2:end)); 
        isImage = 1;
        payloadDim = size(payload); 
    else 
        isImage = 0;
        payloadDim = nan; 
    end 
    
    if (nBits >= 8 || nBits <=0) % function is currently restricted to uint8, behaviour with different colour depths is un-tested
        error('nBits must be between 1 and 7');
    end 
    
    pin = inputParser; 
    pin.addParameter('Order', 'sequential', @ischar); 
    pin.parse(varargin{:}); 
    
    order = pin.Results.Order; 
    if (~ (strcmpi(order, 'sequential') || strcmpi(order, 'pseudo')))
        error('Order specified does not exist'); 
    end 
    
    %% Embed payload into cover image
    originalImg = imread(filename{1}, extension{1}(2:end)); 
    
    % Check bits per sample 
    assert(isa(originalImg, 'uint8'), 'Only a 8-bit colour depth is currently supported'); 
    % Add support for other colour depths in future...will have to parse the 
    % class type of the image and then assign bitsPerSample dynamically.
    % Alternatively, can allow the user to input the colour depth as a function
    % argument, but this is not ideal.
    bitsPerSample = 8; 
    
    % Convert payload to binary values
    if (isImage == 1) 
        payload_bin = de2bi(payload)';
    else 
        payload_bin = de2bi(uint8(payload), bitsPerSample)';  % Convert string into binary ASCII values
    end 
    payload_bin = payload_bin(:); % Concatenate payload into a single column vector
    
    payloadLength = length(payload_bin); 
    nSamples = ceil(payloadLength / nBits); % Calculate capacity required for payload
    
    % Determine if the payload will fit inside the cover image
    imgDim = size(originalImg);
    nPixels = imgDim(1)*imgDim(2);
    if (nSamples > (nPixels*3))
        error('The size of the payload exceeds the capacity of the cover image');
    end  
    
    pixelValues = de2bi(originalImg); % binary pixel values  
      
    if (strcmpi(order, 'pseudo'))
        alloc = randperm(length(pixelValues), length(pixelValues)); % Algorithm for allocating payload
        isPseudo = 1; 
    else 
        alloc = nan;
        isPseudo = 0; 
    end
    
    payloadCounter = 1; 
    
    % This section can be cleaned up to reduce code length, but I opted to
    % reduce the number of computations
    if (isPseudo)
        if (mod(nBits,2)) % If nBits is odd 
            for i = 1:(nSamples-1) 
                pixelValues(alloc(i), 1:nBits) = payload_bin(payloadCounter : payloadCounter + nBits - 1); % Embed payload
                payloadCounter = payloadCounter + nBits; 
            end 
            % When nBits is odd, it doesn't divide evenly into payloadLength, so
            % there are leftover bits in the final sample that have to be accounted for
            bitsRemaining = mod(payloadLength, nBits);
            pixelValues(alloc(nSamples), 1:bitsRemaining) = payload_bin(payloadCounter : payloadCounter + bitsRemaining - 1);
        else 
            for i = 1:nSamples 
                pixelValues(alloc(i), 1:nBits) = payload_bin(payloadCounter : payloadCounter + nBits - 1); % Embed payload
                payloadCounter = payloadCounter + nBits; 
            end 
        end 
    else 
        if (mod(nBits,2)) % If nBits is odd 
            for i = 1:(nSamples-1) 
                pixelValues(i, 1:nBits) = payload_bin(payloadCounter : payloadCounter + nBits - 1); % Embed payload
                payloadCounter = payloadCounter + nBits; 
            end 
            % When nBits is odd, it doesn't divide evenly into payloadLength, so
            % there are leftover bits in the final sample that have to be accounted for
            bitsRemaining = mod(payloadLength, nBits);
            pixelValues(nSamples, 1:bitsRemaining) = payload_bin(payloadCounter : payloadCounter + bitsRemaining - 1);
        else 
            for i = 1:nSamples 
                pixelValues(i, 1:nBits) = payload_bin(payloadCounter : payloadCounter + nBits - 1); % Embed payload
                payloadCounter = payloadCounter + nBits; 
            end 
        end 
    end 
    
    
    % Reconstruct image with embedded message
    pixelValues = bi2de(pixelValues); % uint8 pixel values
    
    stegoImage(:,:,1) = vec2mat(pixelValues(1 : nPixels), imgDim(1))';
    stegoImage(:,:,2) = vec2mat(pixelValues(nPixels+1 : 2*nPixels), imgDim(1))'; 
    stegoImage(:,:,3) = vec2mat(pixelValues(2*nPixels+1 : 3*nPixels), imgDim(1))'; 
    
    imwrite(stegoImage, [filename{1} '_watermarked' extension{1}]);
    
end 