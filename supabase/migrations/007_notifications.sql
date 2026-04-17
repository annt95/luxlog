-- Luxlog: Notifications backend
-- Migration 007

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  recipient_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  actor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('like', 'comment', 'follow', 'tag')),
  photo_id UUID REFERENCES public.photos(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_notifications_recipient_created
  ON public.notifications(recipient_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread
  ON public.notifications(recipient_id, read_at)
  WHERE read_at IS NULL;

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'notifications'
      AND policyname = 'Recipients can view own notifications'
  ) THEN
    CREATE POLICY "Recipients can view own notifications"
      ON public.notifications FOR SELECT
      USING (auth.uid() = recipient_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'notifications'
      AND policyname = 'Recipients can mark notifications as read'
  ) THEN
    CREATE POLICY "Recipients can mark notifications as read"
      ON public.notifications FOR UPDATE
      USING (auth.uid() = recipient_id)
      WITH CHECK (auth.uid() = recipient_id);
  END IF;
END $$;

CREATE OR REPLACE FUNCTION public.create_like_notification()
RETURNS TRIGGER AS $$
DECLARE
  photo_owner UUID;
BEGIN
  SELECT user_id INTO photo_owner
  FROM public.photos
  WHERE id = NEW.photo_id;

  IF photo_owner IS NOT NULL AND photo_owner <> NEW.user_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type, photo_id)
    VALUES (photo_owner, NEW.user_id, 'like', NEW.photo_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.create_comment_notification()
RETURNS TRIGGER AS $$
DECLARE
  photo_owner UUID;
BEGIN
  SELECT user_id INTO photo_owner
  FROM public.photos
  WHERE id = NEW.photo_id;

  IF photo_owner IS NOT NULL AND photo_owner <> NEW.user_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type, photo_id, comment_id)
    VALUES (photo_owner, NEW.user_id, 'comment', NEW.photo_id, NEW.id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.create_follow_notification()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.following_id <> NEW.follower_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type)
    VALUES (NEW.following_id, NEW.follower_id, 'follow');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_like_created_notify'
  ) THEN
    CREATE TRIGGER on_like_created_notify
      AFTER INSERT ON public.likes
      FOR EACH ROW EXECUTE PROCEDURE public.create_like_notification();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_comment_created_notify'
  ) THEN
    CREATE TRIGGER on_comment_created_notify
      AFTER INSERT ON public.comments
      FOR EACH ROW EXECUTE PROCEDURE public.create_comment_notification();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_follow_created_notify'
  ) THEN
    CREATE TRIGGER on_follow_created_notify
      AFTER INSERT ON public.follows
      FOR EACH ROW EXECUTE PROCEDURE public.create_follow_notification();
  END IF;
END $$;
