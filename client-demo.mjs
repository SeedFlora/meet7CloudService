import { createClient } from '@supabase/supabase-js'

const required = ['SUPABASE_URL', 'SUPABASE_PUBLISHABLE_KEY', 'LAB_EMAIL', 'LAB_PASSWORD']
for (const name of required) {
  if (!process.env[name] || process.env[name].includes('REPLACE_ME') || process.env[name].includes('YOUR_PROJECT')) {
    throw new Error(`Isi ${name} di .env terlebih dahulu`)
  }
}

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_PUBLISHABLE_KEY)
const credentials = { email: process.env.LAB_EMAIL, password: process.env.LAB_PASSWORD }

if (process.argv.includes('--signup')) {
  const { data, error } = await supabase.auth.signUp(credentials)
  if (error) throw error
  console.log(data.session ? 'Pendaftaran berhasil dan sesi aktif.' : 'Pendaftaran dikirim. Verifikasi email bila diminta, lalu jalankan npm run demo.')
  process.exit(0)
}

const { data: login, error: loginError } = await supabase.auth.signInWithPassword(credentials)
if (loginError) throw loginError
const userId = login.user.id

const { data: created, error: insertError } = await supabase
  .from('notes')
  .insert({ user_id: userId, title: 'Catatan RLS', content: 'Baris ini hanya terlihat oleh pemilik.' })
  .select('id,title,user_id')
  .single()
if (insertError) throw insertError

const { data: notes, error: listError } = await supabase
  .from('notes')
  .select('id,title,user_id,created_at')
  .order('created_at', { ascending: false })
if (listError) throw listError
console.log(JSON.stringify({ created, visibleCount: notes.length, allBelongToMe: notes.every((n) => n.user_id === userId) }, null, 2))
await supabase.auth.signOut()
