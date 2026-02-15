const Desktop = ({ theme }) => {
  return (
    <div className={`w-full h-full pt-12 pb-0 bg-gradient-to-br ${theme} relative overflow-hidden transition-all duration-1000`}>
      {/* Animated gradient blobs for glass effect visibility */}
      <div className="absolute top-20 left-20 w-96 h-96 bg-blue-500 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-pulse"></div>
      <div className="absolute top-40 right-20 w-96 h-96 bg-purple-500 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-pulse" style={{animationDelay: '2s'}}></div>
      <div className="absolute -bottom-20 left-1/3 w-96 h-96 bg-pink-500 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-pulse" style={{animationDelay: '4s'}}></div>
      
      {/* Desktop workspace - where windows will be displayed */}
      <div className="w-full h-full flex items-center justify-center relative z-10">
        <div className="text-center space-y-4 opacity-40">
          <div className="text-6xl font-bold text-white drop-shadow-lg">Your OS</div>
          <div className="text-xl text-gray-200">Click the grid icon to start</div>
        </div>
      </div>
    </div>
  );
};

export default Desktop;
