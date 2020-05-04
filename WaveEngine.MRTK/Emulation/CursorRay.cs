﻿// Copyright © Wave Engine S.L. All rights reserved. Use is subject to license terms.

using System;
using WaveEngine.Components.Graphics3D;
using WaveEngine.Components.Primitives;
using WaveEngine.Framework;
using WaveEngine.Framework.Graphics;
using WaveEngine.Framework.Physics3D;
using WaveEngine.Framework.Services;
using WaveEngine.Mathematics;

namespace WaveEngine.MRTK.Emulation
{
    /// <summary>
    /// Cursor ray.
    /// </summary>
    public class CursorRay : Behavior
    {
        /// <summary>
        /// The transform.
        /// </summary>
        [BindComponent]
        protected Transform3D transform = null;

        /// <summary>
        /// The cursor to move.
        /// </summary>
        [BindComponent(isRequired: true, source: BindComponentSource.Owner)]
        protected Cursor cursor;

        /// <summary>
        /// Gets or sets the reference cursor to retrieve the Pinch from.
        /// </summary>
        public Cursor MainCursor { get; set; }

        /// <summary>
        /// Gets or sets bezier.
        /// </summary>
        public LineBezierMesh Bezier { get; set; }

        private float pinchDist;
        private Vector3 pinchPosRef;

        /// <inheritdoc/>
        protected override bool OnAttached()
        {
            var attached = base.OnAttached();
            this.UpdateOrder = this.MainCursor.UpdateOrder + 0.1f; // Ensure this is executed always after the main Cursor

            return attached;
        }

        /// <inheritdoc/>
        protected override void Update(TimeSpan gameTime)
        {
            this.Bezier.LinePoints[0].Position = this.MainCursor.transform.Position;
            this.Bezier.LinePoints[1].Position = this.MainCursor.transform.Position + (this.MainCursor.transform.WorldTransform.Forward * (this.transform.Position - this.MainCursor.transform.Position).Length() * 0.75f);
            this.Bezier.LinePoints[2].Position = this.transform.Position;
            this.Bezier.RefreshItems(null);

            Ray r = new Ray(this.MainCursor.transform.Position, this.MainCursor.transform.WorldTransform.Forward);
            if (this.cursor.Pinch)
            {
                float dFactor = (this.MainCursor.transform.Position - this.pinchPosRef).Z;
                dFactor = (float)Math.Pow(1 - dFactor, 10);

                this.transform.Position = r.GetPoint(this.pinchDist * dFactor);
            }
            else
            {
                Vector3 collPoint = r.GetPoint(1000.0f);
                this.transform.Position = collPoint; // Move the cursor to avoid collisions
                HitResult3D result = this.Managers.PhysicManager3D.RayCast(ref r, 1000.0f, CollisionCategory3D.All);

                if (result.Succeeded)
                {
                    collPoint = result.Point;
                }

                float dist = (this.MainCursor.transform.Position - collPoint).Length();
                if (dist > 0.1f)
                {
                    this.transform.Position = collPoint;

                    if (this.MainCursor.Pinch)
                    {
                        // Pinch is about to happen
                        this.pinchDist = dist;
                        this.pinchPosRef = this.MainCursor.transform.Position;
                    }
                }
            }

            this.cursor.Pinch = this.MainCursor.Pinch;
        }
    }
}
