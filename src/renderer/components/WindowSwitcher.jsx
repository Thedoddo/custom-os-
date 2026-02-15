import { useState, useEffect } from 'react';
import { X, Minimize2, Square } from 'lucide-react';
import { motion } from 'framer-motion';

const WindowSwitcher = () => {
  const [windows, setWindows] = useState([]);
  const isLinux = window.electronAPI?.platform === 'linux';

  useEffect(() => {
    if (!isLinux) return;

    const fetchWindows = async () => {
      const windowsList = await window.electronAPI.getWindowsList();
      setWindows(windowsList);
    };

    fetchWindows();
    const interval = setInterval(fetchWindows, 2000); // Refresh every 2 seconds

    return () => clearInterval(interval);
  }, [isLinux]);

  const handleFocusWindow = (windowId) => {
    window.electronAPI.focusWindow(windowId);
  };

  const handleCloseWindow = (windowId) => {
    window.electronAPI.closeAppWindow(windowId);
    setWindows(windows.filter(w => w.id !== windowId));
  };

  if (!isLinux || windows.length === 0) return null;

  return (
    <div className="flex items-center space-x-2 max-w-md overflow-x-auto">
      {windows.map((window) => (
        <motion.div
          key={window.id}
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          className="glass-effect rounded-lg px-3 py-2 flex items-center space-x-2 min-w-fit group"
        >
          <button
            onClick={() => handleFocusWindow(window.id)}
            className="text-xs text-os-text hover:text-white transition-colors max-w-32 truncate"
          >
            {window.title}
          </button>
          <button
            onClick={() => handleCloseWindow(window.id)}
            className="opacity-0 group-hover:opacity-100 transition-opacity"
          >
            <X size={12} className="text-os-text-dim hover:text-red-500" />
          </button>
        </motion.div>
      ))}
    </div>
  );
};

export default WindowSwitcher;
