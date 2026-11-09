import {defineConfig} from 'vite';
import {profileApi} from './profile-server.mjs';
export default defineConfig({plugins:[{name:'project-profile',configureServer(server){server.middlewares.use(profileApi);},configurePreviewServer(server){server.middlewares.use(profileApi);}}]});
