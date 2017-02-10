classdef Bip < handle
    %BIP Generate a bip signal and get it ready for playback via PTB
    
    %% Properties
    
    properties
        
        % Parameters
        
        fs       = zeros(0)   % Sampling frequency (Hertz)
        f0       = zeros(0)   % Base frequency of the sound (Hertz)
        duration = zeros(0)   % Duration of the bip (milliseconds)
        ratio    = zeros(0)   % ratio between the 1 part and the 0 part of the tukey window
        
        % Internal variables
        
        sinusoid = zeros(1,0) % raw sinusoid : f0 sampled by fs
        window   = zeros(1,0) % tukey window
        signal   = zeros(1,0) % signal ready to be played
        
        time     = zeros(1,0) % used to generate the vectors and for plot
        phase    = zeros(0)   % phase of the sinusoid
        
        % Link with PTB
        
        pahandle = zeros(0)   % PsychPortAudio handle == pointer
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = Bip( fs , f0 ,  duration , ratio )
            % obj = Bip( fs=44100 Hz , f0=440 Hz ,  duration=300 ms , ratio=0.25 )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- fs ----
                assert( isscalar(fs) && isnumeric(fs) && fs>0 && fs==round(fs) , 'fs is the sampling frequency (Hertz)' )
                
                % --- f0 ----
                assert( isscalar(f0) && isnumeric(f0) && f0>0 && f0==round(f0) , 'f0 is the base frequency of the sound (Hertz)' )
                
                % --- duration ---
                assert( isscalar(duration) && isnumeric(duration) && duration>0 && duration==round(duration) , 'uration is the length of the bip (milliseconds)' )
                
                % --- ratio ---
                assert( isscalar(ratio) && isnumeric(ratio) && ratio>0 , 'ratio between the 1 part and the 0 part of the tukey window' )
                
                obj.fs       = fs;
                obj.f0       = f0;
                obj.duration = duration;
                obj.ratio    = ratio;
                
                % ================== Callback =============================
                
                obj.GenerateSignal
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
