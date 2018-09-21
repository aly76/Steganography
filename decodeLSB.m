function message = decodeLSB(stegoImage, nSamples, nBits)
    % Decoder for LSB method of steganography
    % Currently only works with 8-bit colour depths
    % Alan Ly & Alex Chin, 2018
    %
    % Inputs 
    % stegoImage - the image with an embedded message to be decoded
    % nSamples - number of samples in the image that contain the
    % message...retrieved from the encoder
    % nBits - number of bits per sample/pixel allocated to the message...set by
    % the encoder
    %
    % Outputs 
    % message - the decoded message
    
    pixelValues = imread(stegoImage);
    pixelValues = de2bi(pixelValues); % binary pixel values 
    
    % Extract message bits from the stegoimage
    counter = 1; 
    for i = 1: nSamples 
        message(counter: counter + nBits - 1) = pixelValues(i, 1:nBits);
        counter = counter + nBits; 
    end 
    
    message = vec2mat(message, 8); % Group the message bits into bytes to be converted 
    message = bi2de(message); % message ASCII values
    message = char(message)'; % convert into readable characters
end 