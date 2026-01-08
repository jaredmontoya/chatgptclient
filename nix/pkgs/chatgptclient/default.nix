{
  self,
  lib,
  buildNimPackage,
  pkg-config,
  openssl,
  gtk4,
  libadwaita,
}:

buildNimPackage {
  pname = "chatgptclient";
  version = "0.2.0";
  src = self;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    gtk4
    libadwaita
  ];

  lockFile = ./lock.json;

  meta = with lib; {
    description = "OpenAI API compatible GTK4 chat client";
    homepage = "https://github.com/jaredmontoya/chatgptclient";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ jaredmontoya ];
    platforms = platforms.linux;
    mainProgram = "chatgptclient";
  };
}
