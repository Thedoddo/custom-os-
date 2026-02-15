import { motion, AnimatePresence } from 'framer-motion';
import { X, Image, Code, Folder, Music, Video, Settings, Terminal, Chrome, FileText } from 'lucide-react';

const mockApps = [
  { id: 1, name: 'Studio', icon: Image, category: 'Creative', color: 'from-purple-500 to-pink-500' },
  { id: 2, name: 'Code', icon: Code, category: 'Development', color: 'from-blue-500 to-cyan-500' },
  { id: 3, name: 'Files', icon: Folder, category: 'System', color: 'from-yellow-500 to-orange-500' },
  { id: 4, name: 'Sounds', icon: Music, category: 'Creative', color: 'from-green-500 to-emerald-500' },
  { id: 5, name: 'Cinema', icon: Video, category: 'Creative', color: 'from-red-500 to-rose-500' },
  { id: 6, name: 'Settings', icon: Settings, category: 'System', color: 'from-gray-500 to-slate-500' },
  { id: 7, name: 'Console', icon: Terminal, category: 'Development', color: 'from-indigo-500 to-purple-500' },
  { id: 8, name: 'Browser', icon: Chrome, category: 'Productivity', color: 'from-teal-500 to-cyan-500' },
  { id: 9, name: 'Notes', icon: FileText, category: 'Productivity', color: 'from-amber-500 to-yellow-500' },
];

const Launcher = ({ isOpen, onClose }) => {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.2 }}
          className="absolute inset-0 z-50"
        >
          {/* Backdrop */}
          <div 
            className="absolute inset-0 bg-black bg-opacity-60 backdrop-blur-xl"
            onClick={onClose}
          />
          
          {/* Launcher Content */}
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.9, opacity: 0 }}
            transition={{ duration: 0.2, ease: 'easeOut' }}
            className="absolute inset-0 flex flex-col items-center justify-center p-12"
          >
            {/* Close Button */}
            <button
              onClick={onClose}
              className="absolute top-8 right-8 w-12 h-12 rounded-full bg-os-light hover:bg-os-lighter transition-colors flex items-center justify-center"
            >
              <X size={24} className="text-os-text" />
            </button>

            {/* Search Bar */}
            <div className="w-full max-w-2xl mb-12">
              <input
                type="text"
                placeholder="Search apps, files, and more..."
                className="w-full h-16 glass-elevated rounded-2xl px-6 text-lg text-os-text border-transparent focus:border-os-accent outline-none transition-all"
                autoFocus
              />
            </div>

            {/* App Grid */}
            <div className="grid grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6 max-w-5xl">
              {mockApps.map((app, index) => (
                <motion.div
                  key={app.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.05, duration: 0.3 }}
                  className="flex flex-col items-center space-y-3 cursor-pointer group"
                  onClick={onClose}
                >
                  <div className={`w-24 h-24 rounded-3xl bg-gradient-to-br ${app.color} flex items-center justify-center hover-lift shadow-lg glass-elevated`}>
                    <app.icon size={40} className="text-white" />
                  </div>
                  <div className="text-center">
                    <div className="text-sm font-medium text-os-text group-hover:text-os-accent transition-colors">
                      {app.name}
                    </div>
                    <div className="text-xs text-os-text-dim">{app.category}</div>
                  </div>
                </motion.div>
              ))}
            </div>

            {/* Categories at bottom */}
            <div className="absolute bottom-12 flex space-x-4">
              {['All', 'Creative', 'Development', 'Productivity', 'System'].map((category) => (
                <button
                  key={category}
                  className="px-6 py-2 rounded-full glass-effect hover:glass-elevated transition-all text-sm text-os-text"
                >
                  {category}
                </button>
              ))}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default Launcher;
