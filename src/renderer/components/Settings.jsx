import { motion, AnimatePresence } from 'framer-motion';
import { X, Monitor, Palette, Sliders, Info, Wifi, Bell, Lock, HardDrive, Layout } from 'lucide-react';
import { useState } from 'react';

const SettingsPanel = ({ isOpen, onClose, blurIntensity, setBlurIntensity, transparency, setTransparency, theme, setTheme, themeColor, layoutSettings, setLayoutSettings }) => {
  const [activeTab, setActiveTab] = useState('appearance');

  const tabs = [
    { id: 'appearance', label: 'Appearance', icon: Palette },
    { id: 'layout', label: 'Layout', icon: Layout },
    { id: 'display', label: 'Display', icon: Monitor },
    { id: 'system', label: 'System', icon: Sliders },
    { id: 'network', label: 'Network', icon: Wifi },
    { id: 'notifications', label: 'Notifications', icon: Bell },
    { id: 'privacy', label: 'Privacy', icon: Lock },
    { id: 'about', label: 'About', icon: Info },
  ];

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="absolute inset-0 z-40 flex items-center justify-center p-8"
        >
          {/* Backdrop */}
          <div 
            className="absolute inset-0 bg-black bg-opacity-40"
            onClick={onClose}
          />
          
          {/* Settings Panel */}
          <motion.div
            initial={{ scale: 0.95, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.95, opacity: 0 }}
            className="relative w-full max-w-5xl h-[600px] glass-elevated rounded-3xl flex overflow-hidden shadow-2xl"
          >
            {/* Sidebar */}
            <div className="w-64 glass-effect border-r border-white/10 p-6 flex flex-col">
              <div className="mb-8">
                <h2 className="text-2xl font-bold text-os-text">Settings</h2>
                <p className="text-sm text-os-text-dim mt-1">Customize your system</p>
              </div>
              
              <nav className="flex-1 space-y-2">
                {tabs.map((tab) => {
                  const Icon = tab.icon;
                  return (
                    <button
                      key={tab.id}
                      onClick={() => setActiveTab(tab.id)}
                      className={`w-full flex items-center space-x-3 px-4 py-3 rounded-xl transition-all ${
                        activeTab === tab.id
                          ? 'text-white'
                          : 'text-os-text hover:bg-white/5'
                      }`}
                      style={activeTab === tab.id ? {
                        backgroundColor: themeColor?.accent || '#6366f1'
                      } : {}}
                    >
                      <Icon size={20} />
                      <span className="font-medium">{tab.label}</span>
                    </button>
                  );
                })}
              </nav>
            </div>

            {/* Content Area */}
            <div className="flex-1 p-8 overflow-y-auto">
              <button
                onClick={onClose}
                className="absolute top-6 right-6 w-10 h-10 rounded-full glass-effect hover:glass-elevated transition-all flex items-center justify-center"
              >
                <X size={20} className="text-os-text" />
              </button>

              {/* Appearance Tab */}
              {activeTab === 'appearance' && (
                <div className="space-y-6">
                  <div>
                    <h3 className="text-xl font-bold text-os-text mb-4">Appearance</h3>
                    <p className="text-os-text-dim mb-6">Customize the look and feel of your system</p>
                  </div>

                  {/* Glass Effect Controls */}
                  <div className="glass-effect rounded-2xl p-6 space-y-6">
                    <div>
                      <label className="text-sm font-medium text-os-text mb-2 block">
                        Blur Intensity: {blurIntensity}px
                      </label>
                      <input
                        type="range"
                        min="0"
                        max="100"
                        value={blurIntensity}
                        onChange={(e) => setBlurIntensity(e.target.value)}
                        className="w-full h-2 bg-os-light rounded-lg appearance-none cursor-pointer"
                        style={{
                          accentColor: themeColor?.accent || '#6366f1'
                        }}
                      />
                    </div>

                    <div>
                      <label className="text-sm font-medium text-os-text mb-2 block">
                        Transparency: {transparency}%
                      </label>
                      <input
                        type="range"
                        min="0"
                        max="100"
                        value={transparency}
                        onChange={(e) => setTransparency(e.target.value)}
                        className="w-full h-2 bg-os-light rounded-lg appearance-none cursor-pointer"
                        style={{
                          accentColor: themeColor?.accent || '#6366f1'
                        }}
                      />
                    </div>
                  </div>

                  {/* Theme Selection */}
                  <div>
                    <h4 className="text-sm font-medium text-os-text mb-3">Theme</h4>
                    <div className="grid grid-cols-2 gap-4">
                      <div 
                        onClick={() => setTheme('purple')}
                        className={`glass-effect rounded-2xl p-4 cursor-pointer hover:glass-elevated transition-all border-2`}
                        style={{ borderColor: theme === 'purple' ? '#818cf8' : 'transparent' }}
                      >
                        <div className="w-full h-20 bg-gradient-to-br from-indigo-900 to-purple-900 rounded-lg mb-3"></div>
                        <p className="text-sm font-medium text-os-text">Dark Purple</p>
                        {theme === 'purple' && <p className="text-xs text-os-text-dim">Current</p>}
                      </div>
                      <div 
                        onClick={() => setTheme('ocean')}
                        className={`glass-effect rounded-2xl p-4 cursor-pointer hover:glass-elevated transition-all border-2`}
                        style={{ borderColor: theme === 'ocean' ? '#22d3ee' : 'transparent' }}
                      >
                        <div className="w-full h-20 bg-gradient-to-br from-blue-900 to-cyan-900 rounded-lg mb-3"></div>
                        <p className="text-sm font-medium text-os-text">Ocean Blue</p>
                        {theme === 'ocean' && <p className="text-xs text-os-text-dim">Current</p>}
                      </div>
                      <div 
                        onClick={() => setTheme('midnight')}
                        className={`glass-effect rounded-2xl p-4 cursor-pointer hover:glass-elevated transition-all border-2`}
                        style={{ borderColor: theme === 'midnight' ? '#94a3b8' : 'transparent' }}
                      >
                        <div className="w-full h-20 bg-gradient-to-br from-gray-900 to-slate-900 rounded-lg mb-3"></div>
                        <p className="text-sm font-medium text-os-text">Midnight</p>
                        {theme === 'midnight' && <p className="text-xs text-os-text-dim">Current</p>}
                      </div>
                      <div 
                        onClick={() => setTheme('sunset')}
                        className={`glass-effect rounded-2xl p-4 cursor-pointer hover:glass-elevated transition-all border-2`}
                        style={{ borderColor: theme === 'sunset' ? '#fb923c' : 'transparent' }}
                      >
                        <div className="w-full h-20 bg-gradient-to-br from-orange-900 to-red-900 rounded-lg mb-3"></div>
                        <p className="text-sm font-medium text-os-text">Sunset</p>
                        {theme === 'sunset' && <p className="text-xs text-os-text-dim">Current</p>}
                      </div>
                    </div>
                  </div>
                </div>
              )}
Layout Tab */}
              {activeTab === 'layout' && (
                <div className="space-y-6">
                  <div>
                    <h3 className="text-xl font-bold text-os-text mb-4">Layout & Window Management</h3>
                    <p className="text-os-text-dim mb-6">Customize how windows and controls appear</p>
                  </div>

                  {/* Title Bar Position */}
                  <div>
                    <h4 className="text-sm font-medium text-os-text mb-3">Title Bar Position</h4>
                    <div className="grid grid-cols-2 gap-4">
                      <button
                        onClick={() => setLayoutSettings({...layoutSettings, titleBarPosition: 'top'})}
                        className={`glass-effect rounded-2xl p-4 transition-all border-2 hover:glass-elevated`}
                        style={{ borderColor: layoutSettings.titleBarPosition === 'top' ? themeColor?.accent : 'transparent' }}
                      >
                        <div className="w-full h-16 bg-os-darker rounded-lg mb-2 relative">
                          <div className="absolute top-0 left-0 right-0 h-2 bg-gradient-to-r" style={{background: themeColor?.accent}}></div>
                        </div>
                        <p className="text-sm text-os-text">Top Bar</p>
                      </button>
                      <button
                        onClick={() => setLayoutSettings({...layoutSettings, titleBarPosition: 'bottom'})}
                        className={`glass-effect rounded-2xl p-4 transition-all border-2 hover:glass-elevated`}
                        style={{ borderColor: layoutSettings.titleBarPosition === 'bottom' ? themeColor?.accent : 'transparent' }}
                      >
                        <div className="w-full h-16 bg-os-darker rounded-lg mb-2 relative">
                          <div className="absolute bottom-0 left-0 right-0 h-2 bg-gradient-to-r" style={{background: themeColor?.accent}}></div>
                        </div>
                        <p className="text-sm text-os-text">Bottom Bar</p>
                      </button>
                    </div>
                  </div>

                  {/* Window Style */}
                  <div>
                    <h4 className="text-sm font-medium text-os-text mb-3">Window Controls Style</h4>
                    <div className="grid grid-cols-3 gap-4">
                      <button
                        onClick={() => setLayoutSettings({...layoutSettings, windowStyle: 'modern', controlsPosition: 'right'})}
                        className={`glass-effect rounded-2xl p-4 transition-all border-2 hover:glass-elevated`}
                        style={{ borderColor: layoutSettings.windowStyle === 'modern' ? themeColor?.accent : 'transparent' }}
                      >
                        <div className="flex items-center justify-end space-x-1 mb-2">
                          <div className="w-3 h-3 bg-os-text-dim rounded"></div>
                          <div className="w-3 h-3 bg-os-text-dim rounded"></div>
                          <div className="w-3 h-3 bg-red-500 rounded"></div>
                        </div>
                        <p className="text-xs text-os-text">Modern</p>
                        <p className="text-xs text-os-text-dim">Windows-style</p>
                      </button>
                      <button
                        onClick={() => setLayoutSettings({...layoutSettings, windowStyle: 'mac', controlsPosition: 'left'})}
                        className={`glass-effect rounded-2xl p-4 transition-all border-2 hover:glass-elevated`}
                        style={{ borderColor: layoutSettings.windowStyle === 'mac' ? themeColor?.accent : 'transparent' }}
                      >
                        <div className="flex items-center space-x-1 mb-2">
                          <div className="w-3 h-3 bg-red-500 rounded-full"></div>
                          <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
                          <div className="w-3 h-3 bg-green-500 rounded-full"></div>
                        </div>
                        <p className="text-xs text-os-text">macOS</p>
                        <p className="text-xs text-os-text-dim">Traffic lights</p>
                      </button>
                      <button
                        onClick={() => setLayoutSettings({...layoutSettings, windowStyle: 'minimal'})}
                        className={`glass-effect rounded-2xl p-4 transition-all border-2 hover:glass-elevated`}
                        style={{ borderColor: layoutSettings.windowStyle === 'minimal' ? themeColor?.accent : 'transparent' }}
                      >
                        <div className="flex items-center justify-end space-x-1 mb-2">
                          <div className="w-2 h-0.5 bg-os-text-dim"></div>
                          <div className="w-2 h-2 border border-os-text-dim"></div>
                          <div className="w-2 h-2 relative">
                            <div className="absolute w-2 h-0.5 bg-os-text-dim rotate-45"></div>
                            <div className="absolute w-2 h-0.5 bg-os-text-dim -rotate-45"></div>
                          </div>
                        </div>
                        <p className="text-xs text-os-text">Minimal</p>
                        <p className="text-xs text-os-text-dim">Simple icons</p>
                      </button>
                    </div>
                  </div>

                  {/* Window Management */}
                  <div>
                    <h4 className="text-sm font-medium text-os-text mb-3">Window Management</h4>
                    <div className="grid grid-cols-3 gap-4">
                      <button
                        onClick={() => setLayoutSettings({...layoutSettings, windowManagement: 'floating'})}
                        className={`glass-effect rounded-2xl p-4 transition-all border-2 hover:glass-elevated`}
                        style={{ borderColor: layoutSettings.windowManagement === 'floating' ? themeColor?.accent : 'transparent' }}
                      >
                        <div className="relative h-16 mb-2">
                          <div className="absolute w-12 h-10 bg-os-light rounded border border-os-text-dim top-1 left-2"></div>
                          <div className="absolute w-12 h-10 bg-os-light rounded border border-os-text-dim top-4 left-6"></div>
                        </div>
                        <p className="text-xs text-os-text">Floating</p>
                      </button>
                      <button
                        onClick={() => setLayoutSettings({...layoutSettings, windowManagement: 'tiling'})}
                        className={`glass-effect rounded-2xl p-4 transition-all border-2 hover:glass-elevated`}
                        style={{ borderColor: layoutSettings.windowManagement === 'tiling' ? themeColor?.accent : 'transparent' }}
                      >
                        <div className="grid grid-cols-2 gap-1 h-16 mb-2">
                          <div className="bg-os-light rounded border border-os-text-dim"></div>
                          <div className="bg-os-light rounded border border-os-text-dim"></div>
                          <div className="bg-os-light rounded border border-os-text-dim"></div>
                          <div className="bg-os-light rounded border border-os-text-dim"></div>
                        </div>
                        <p className="text-xs text-os-text">Tiling</p>
                      </button>
                      <button
                        onClick={() => setLayoutSettings({...layoutSettings, windowManagement: 'stacking'})}
                        className={`glass-effect rounded-2xl p-4 transition-all border-2 hover:glass-elevated`}
                        style={{ borderColor: layoutSettings.windowManagement === 'stacking' ? themeColor?.accent : 'transparent' }}
                      >
                        <div className="relative h-16 mb-2">
                          <div className="absolute w-14 h-12 bg-os-light rounded border border-os-text-dim top-0 left-1/2 transform -translate-x-1/2"></div>
                        </div>
                        <p className="text-xs text-os-text">Stacking</p>
                      </button>
                    </div>
                  </div>

                  {/* Dock Option */}
                  <div className="glass-effect rounded-2xl p-6">
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="text-sm font-medium text-os-text">Show Application Dock</p>
                        <p className="text-xs text-os-text-dim mt-1">Display a dock for quick app access</p>
                      </div>
                      <button
                        onClick={() => setLayoutSettings({...layoutSettings, showDock: !layoutSettings.showDock})}
                        className={`w-12 h-6 rounded-full transition-all ${layoutSettings.showDock ? 'glass-elevated' : 'glass-effect'}`}
                        style={{ backgroundColor: layoutSettings.showDock ? themeColor?.accent : 'transparent' }}
                      >
                        <div className={`w-5 h-5 bg-white rounded-full transition-transform ${layoutSettings.showDock ? 'translate-x-6' : 'translate-x-0.5'}`}></div>
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {/* 
              {/* Display Tab */}
              {activeTab === 'display' && (
                <div className="space-y-6">
                  <div>
                    <h3 className="text-xl font-bold text-os-text mb-4">Display</h3>
                    <p className="text-os-text-dim mb-6">Adjust display settings</p>
                  </div>

                  <div className="glass-effect rounded-2xl p-6">
                    <div className="flex items-center justify-between mb-4">
                      <div>
                        <p className="text-sm font-medium text-os-text">Resolution</p>
                        <p className="text-xs text-os-text-dim">1920 × 1080</p>
                      </div>
                      <button className="px-4 py-2 rounded-lg glass-effect hover:glass-elevated transition-all text-sm text-os-text">
                        Change
                      </button>
                    </div>
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="text-sm font-medium text-os-text">Scale</p>
                        <p className="text-xs text-os-text-dim">100%</p>
                      </div>
                      <button className="px-4 py-2 rounded-lg glass-effect hover:glass-elevated transition-all text-sm text-os-text">
                        Adjust
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {/* About Tab */}
              {activeTab === 'about' && (
                <div className="space-y-6">
                  <div>
                    <h3 className="text-xl font-bold text-os-text mb-4">About</h3>
                  </div>

                  <div className="glass-effect rounded-2xl p-6 text-center">
                    <div className="w-24 h-24 bg-gradient-to-br from-os-accent to-purple-600 rounded-3xl mx-auto mb-4 flex items-center justify-center">
                      <Monitor size={48} className="text-white" />
                    </div>
                    <h4 className="text-2xl font-bold text-os-text mb-2">Your Custom OS</h4>
                    <p className="text-os-text-dim mb-4">Version 1.0.0</p>
                    <div className="space-y-2 text-sm text-os-text-dim">
                      <p>Built with Electron + React</p>
                      <p>Designed for the future</p>
                    </div>
                  </div>

                  <div className="glass-effect rounded-2xl p-6 space-y-3">
                    <div className="flex justify-between">
                      <span className="text-os-text-dim">System</span>
                      <span className="text-os-text font-medium">Custom OS</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-os-text-dim">Processor</span>
                      <span className="text-os-text font-medium">Available</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-os-text-dim">Memory</span>
                      <span className="text-os-text font-medium">8 GB</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-os-text-dim">Storage</span>
                      <span className="text-os-text font-medium">256 GB</span>
                    </div>
                  </div>
                </div>
              )}

              {/* Placeholder for other tabs */}
              {['system', 'network', 'notifications', 'privacy'].includes(activeTab) && (
                <div className="space-y-6">
                  <div>
                    <h3 className="text-xl font-bold text-os-text mb-4 capitalize">{activeTab}</h3>
                    <p className="text-os-text-dim mb-6">{activeTab} settings coming soon</p>
                  </div>
                  <div className="glass-effect rounded-2xl p-12 text-center">
                    <HardDrive size={64} className="text-os-text-dim mx-auto mb-4" />
                    <p className="text-os-text-dim">This section is under development</p>
                  </div>
                </div>
              )}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default SettingsPanel;
