CinciMiata Preview Site - Quick Start

Test Credentials:
- Admin: admin1 / PreviewAdmin123!
- Member: member1 / PreviewMember123!
- Guest: guest1 / PreviewGuest123!

Instructions:
1. Build Docker image:
   docker build -t kbogart/cincimiata-preview:latest .
2. Log into Docker Hub:
   docker login
3. Push to Docker Hub:
   docker push kbogart/cincimiata-preview:latest
4. Deploy on Render:
   - New Web Service → Deploy existing image
   - Image: kbogart/cincimiata-preview:latest
   - Expose port 80
   - Add Custom Domain: preview.cincimiata.com
