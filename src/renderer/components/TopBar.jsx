import { useState, useEffect } from 'react';
import { Search, Grid3x3, Minimize2, Square, X, Settings } from 'lucide-react';
import WindowSwitcher from './WindowSwitcher';

const TopBar = ({ onLauncherClick, onSettingsClick, themeColor, layoutSettings }) => {
  const [time, setTime] = useState(new Date());
  const isLinux = window.electronAPI?.platform === 'linux';

  useEffect(() => {
    const timer = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  const formatTime = (date) => {
    return date.toLocaleTimeString('en-US', { 
      hour: '2-digit', 
      minute: '2-digit',
      hour12: true 
    });
  };

  const formatDate = (date) => {
    return date.toLocaleDateString('en-US', { 
      weekday: 'short', 
      month: 'short', 
      day: 'numeric' 
    });
  };

  const handleMinimize = () => {
    window.electronAPI?.minimizeWindow();
  };

  const handleMaximize = () => {
    window.electronAPI?.maximizeWindow();
  };

  const handleClose = () => {
    window.electronAPI?.closeWindow();
  };

  // Determine control button order based on style
  const renderControls = () => {
    if (layoutSettings.windowStyle === 'mac') {
      // Mac style: close, minimize, maximize on left
      return (
        <>
          <button
            onClick={handleClose}
            className="w-8 h-8 rounded-full hover:bg-red-500 transition-all flex items-center justify-center group"
            title="Close"
          >
            <X size={14} className="text-os-text group-hover:text-white" />
          </button>
          <button
            onClick={handleMinimize}
            className="w-8 h-8 rounded-full hover:bg-yellow-500 transition-all flex items-center justify-center group"
            title="Minimize"
          >
            <Minimize2 size={14} className="text-os-text group-hover:text-white" />
          </button>
          <button
            onClick={handleMaximize}
            className="w-8 h-8 rounded-full hover:bg-green-500 transition-all flex items-center justify-center group"
            title="Maximize"
          >
            <Square size={14} className="text-os-text group-hover:text-white" />
          </button>
        </>
      );
    } else if (layoutSettings.windowStyle === 'minimal') {
      // Minimal style: just icons
      return (
        <>
          <button
            onClick={handleMinimize}
            className="w-6 h-6 hover:bg-os-light transition-colors flex items-center justify-center rounded"
            title="Minimize"
          >
            <div className="w-3 h-0.5 bg-os-text"></div>
          </button>
          <button
            onClick={handleMaximize}
            className="w-6 h-6 hover:bg-os-light transition-colors flex items-center justify-center rounded"
            title="Maximize"
          >
            <div className="w-3 h-3 border border-os-text"></div>
          </button>
          <button
            onClick={handleClose}
            className="w-6 h-6 hover:bg-red-600 transition-colors flex items-center justify-center rounded"
            title="Close"
          >
            <div className="relative w-3 h-3">
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="w-3 h-0.5 bg-os-text rotate-45"></div>
                <div className="w-3 h-0.5 bg-os-text -rotate-45 absolute"></div>
              </div>
            </div>
          </button>
        </>
      );
    } else {
      // Windows/Modern style: minimize, maximize, close on right
      return (
        <>
          <button
            onClick={handleMinimize}
            className="w-8 h-8 rounded-lg hover:bg-os-light transition-colors flex items-center justify-center"
            title="Minimize"
          >
            <Minimize2 size={16} className="text-os-text" />
          </button>
          <button
            onClick={handleMaximize}
            className="w-8 h-8 rounded-lg hover:bg-os-light transition-colors flex items-center justify-center"
            title="Maximize"
          >
            <Square size={16} className="text-os-text" />
          </button>
          <button
            onClick={handleClose}
            className="w-8 h-8 rounded-lg hover:bg-red-600 transition-colors flex items-center justify-center"
            title="Close"
          >
            <X size={16} className="text-os-text" />
          </button>
        </>
      );
    }
  };

  const isTopBar = layoutSettings.titleBarPosition === 'top';
  const isBottomBar = layoutSettings.titleBarPosition === 'bottom';
  const controlsOnLeft = layoutSettings.controlsPosition === 'left' || layoutSettings.windowStyle === 'mac';

  return (
    <div className={`absolute ${isTopBar ? 'top-0' : isBottomBar ? 'bottom-0' : 'top-0'} left-0 right-0 h-12 glass-effect z-50 flex items-center justify-between px-4`}>
      {/* Left Section&& !isLinux  - Launcher & Search OR Window Controls */}
      {controlsOnLeft ? (
        <div className="flex items-center space-x-2">
          {renderControls()}
        </div>
      ) : (
        <div className="flex items-center space-x-3">
        <button
          onClick={onLauncherClick}
          className="w-8 h-8 rounded-lg transition-all flex items-center justify-center"
          style={{ 
            backgroundColor: themeColor?.accent || '#6366f1',
            '&:hover': { backgroundColor: themeColor?.accentHover || '#818cf8' }
          }}
          onMouseEnter={(e) => e.currentTarget.style.backgroundColor = themeColor?.accentHover || '#818cf8'}
          onMouseLeave={(e) => e.currentTarget.style.backgroundColor = themeColor?.accent || '#6366f1'}
          title="Open Launcher"
        >
          <Grid3x3 size={18} className="text-white" />
        </button>
        
        <div className="w-64 h-8 glass-effect rounded-lg flex items-center px-3 space-x-2 hover:glass-elevated transition-all cursor-pointer">
          <Search size={16} className="text-os-text-dim" />
          <input 
            type="text" 
            placeholder="Search everything..."
            className="bg-transparent border-none outline-none text-sm text-os-text w-full placeholder:text-os-text-dim"
          />
        </div>
      </div>
      )}

      {/* Center Section - Time & Date OR Window Switcher */}
      <div className="flex flex-col items-center">
        {isLinux ? (
          <WindowSwitcher />
        ) : (
          <>
            <div className="text-sm font-medium text-os-text">{formatTime(time)}</div>
            <div className="text-xs text-os-text-dim">{formatDate(time)}</div>
          </>
        )}
      </div>

      {/* Right Section - Settings & Controls OR Just Settings */}
      {!controlsOnLeft && !isLinux ? (
        <div className="flex items-center space-x-2">
          <button
            onClick={onSettingsClick}
            className="w-8 h-8 rounded-lg glass-effect hover:glass-elevated transition-all flex items-center justify-center"
            title="Settings"
          >
            <Settings size={16} className="text-os-text" />
          </button>
          {renderControls()}
        </div>
      ) : (
        <div className="flex items-center space-x-2">
          <button
            onClick={onSettingsClick}
            className="w-8 h-8 rounded-lg glass-effect hover:glass-elevated transition-all flex items-center justify-center"
            title="Settings"
          >
            <Settings size={16} className="text-os-text" />
          </button>
        </div>
      )}
    </div>
  );
};

export default TopBar;
