import { useState, useEffect } from 'react';
import TopBar from './components/TopBar';
import Desktop from './components/Desktop';
import Launcher from './components/Launcher';
import Settings from './components/Settings';

function App() {
  const [launcherOpen, setLauncherOpen] = useState(false);
  const [settingsOpen, setSettingsOpen] = useState(false);
  const [blurIntensity, setBlurIntensity] = useState(40);
  const [transparency, setTransparency] = useState(40);
  const [theme, setTheme] = useState('purple');
  const [layoutSettings, setLayoutSettings] = useState({
    titleBarPosition: 'top',
    windowStyle: 'modern',
    windowManagement: 'floating',
    controlsPosition: 'right',
    showDock: false,
  });

  const themes = {
    purple: {
      gradient: 'from-indigo-900 via-purple-900 to-pink-900',
      accent: '#818cf8',
      accentHover: '#a5b4fc'
    },
    ocean: {
      gradient: 'from-blue-900 via-cyan-900 to-teal-900',
      accent: '#22d3ee',
      accentHover: '#67e8f9'
    },
    midnight: {
      gradient: 'from-gray-900 via-slate-900 to-zinc-900',
      accent: '#94a3b8',
      accentHover: '#cbd5e1'
    },
    sunset: {
      gradient: 'from-orange-900 via-red-900 to-pink-900',
      accent: '#fb923c',
      accentHover: '#fdba74'
    },
  };

  // Apply glass effect settings to CSS variables
  useEffect(() => {
    document.documentElement.style.setProperty('--blur-intensity', `${blurIntensity}px`);
    document.documentElement.style.setProperty('--transparency', `${transparency / 100}`);
  }, [blurIntensity, transparency]);

  const toggleLauncher = () => {
    setLauncherOpen(!launcherOpen);
  };

  const toggleSettings = () => {
    setSettingsOpen(!settingsOpen);
  };

  return (
    <div className="w-full h-full bg-os-dark relative overflow-hidden">
      {/* Desktop Workspace */}
      <Desktop theme={themes[theme].gradient} />
      
      {/* Top Bar */}
      <TopBar 
        onLauncherClick={toggleLauncher} 
        onSettingsClick={toggleSettings} 
        themeColor={themes[theme]}
        layoutSettings={layoutSettings}
      />
      
      {/* Launcher Overlay */}
      <Launcher isOpen={launcherOpen} onClose={() => setLauncherOpen(false)} />
      
      {/* Settings Panel */}
      <Settings 
        isOpen={settingsOpen} 
        onClose={() => setSettingsOpen(false)}
        blurIntensity={blurIntensity}
        setBlurIntensity={setBlurIntensity}
        layoutSettings={layoutSettings}
        setLayoutSettings={setLayoutSettings}
        transparency={transparency}
        setTransparency={setTransparency}
        theme={theme}
        setTheme={setTheme}
        themeColor={themes[theme]}
      />
    </div>
  );
}

export default App;
