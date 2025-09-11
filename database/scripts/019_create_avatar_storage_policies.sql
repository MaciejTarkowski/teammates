-- Create a policy for viewing avatars
CREATE POLICY "Public avatars are viewable by everyone."
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );

-- Create a policy for uploading avatars
CREATE POLICY "Anyone can upload an avatar."
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'avatars' );

-- Create a policy for updating avatars
CREATE POLICY "Anyone can update their own avatar."
ON storage.objects FOR UPDATE
USING ( auth.uid() = owner )
WITH CHECK ( bucket_id = 'avatars' );

-- Create a policy for deleting avatars
CREATE POLICY "Anyone can delete their own avatar."
ON storage.objects FOR DELETE
USING ( auth.uid() = owner );
