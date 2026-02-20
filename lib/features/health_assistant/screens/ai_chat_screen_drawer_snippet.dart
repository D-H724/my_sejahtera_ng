  Widget _buildHistoryDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: SafeArea(
        child: Column(
          children: [
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text("Chat History", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
             ),
             const Divider(color: Colors.white24),
             Expanded(
               child: FutureBuilder<List<ChatSessionModel>>(
                 future: ref.read(chatProvider.notifier).fetchHistory(),
                 builder: (context, snapshot) {
                   if (snapshot.connectionState == ConnectionState.waiting) {
                     return const Center(child: CircularProgressIndicator());
                   }
                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
                     return const Center(child: Text("No history yet", style: TextStyle(color: Colors.white54)));
                   }
                   
                   final sessions = snapshot.data!;
                   return ListView.builder(
                     itemCount: sessions.length,
                     itemBuilder: (context, index) {
                       final session = sessions[index];
                       final isCurrent = session.id == ref.read(chatProvider.notifier).currentSessionId;
                       
                       return ListTile(
                         title: Text(session.title, style: TextStyle(color: isCurrent ? Colors.blueAccent : Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                         subtitle: Text(DateFormat.MMMd().format(session.createdAt), style: const TextStyle(color: Colors.white30, fontSize: 10)),
                         onTap: () {
                           ref.read(chatProvider.notifier).loadSession(session.id);
                           Navigator.pop(context); // Close drawer
                         },
                         trailing: IconButton(
                           icon: const Icon(LucideIcons.trash2, color: Colors.white24, size: 16),
                           onPressed: () async {
                              await ref.read(chatProvider.notifier).deleteSession(session.id);
                              setState(() {}); // Refresh drawer
                           },
                         ),
                       );
                     },
                   );
                 },
               ),
             ),
          ],
        ),
      ),
    );
  }
